# frozen_string_literal: true

require 'segment/analytics/defaults'
require 'segment/analytics/utils'
require 'segment/analytics/response'
require 'segment/analytics/logging'
require 'segment/analytics/backoff_policy'
require 'segment/analytics/retry_budget'
require 'net/http'
require 'net/https'
require 'json'
require 'time'

module Segment
  class Analytics
    class Transport
      include Segment::Analytics::Defaults::Request
      include Segment::Analytics::Utils
      include Segment::Analytics::Logging

      RETRYABLE_4XX     = [408, 410, 429, 460].freeze
      NON_RETRYABLE_5XX = [501, 505, 511].freeze

      def initialize(options = {})
        options[:host] ||= HOST
        options[:port] ||= PORT
        options[:ssl]  ||= SSL
        @headers = options[:headers] || HEADERS
        @path    = options[:path]    || PATH

        configure_retries(options)
        @http = build_http(options)
      end

      # Sends a batch of messages to the API
      #
      # @return [Response] API response
      def send(write_key, batch)
        logger.debug("Sending request for #{batch.length} items")

        @backoff_policy.reset! if @backoff_policy.respond_to?(:reset!)
        budget = new_retry_budget

        loop do
          begin
            status_code, body, headers = send_request(write_key, batch, budget.retry_count)
          rescue StandardError => e
            # Connection reset, DNS failure, read timeout and friends. Retried on
            # the counted backoff budget, like a retryable status code.
            logger.error("Network error: #{e.message}")
            return Response.new(-1, e.to_s) unless wait_to_retry(budget.next_backoff_delay, budget)

            next
          end

          error = parse_error(body)
          final = final_response(status_code, body, error)
          return final if final

          delay = retry_delay(status_code, headers, budget)
          return Response.new(status_code, error) unless wait_to_retry(delay, budget)
        end
      rescue StandardError => e
        logger.error(e.message)
        e.backtrace.each { |line| logger.error(line) }
        Response.new(-1, e.to_s)
      end

      # Closes a persistent connection if it exists
      def shutdown
        @http.finish if @http.started?
      end

      private

      # A Response once the batch is settled, or nil while it is still retryable.
      def final_response(status_code, body, error)
        logger.debug("Response status code: #{status_code}")
        logger.debug("Response error: #{error}") if error

        return Response.new(status_code, error) if success_status?(status_code)
        return nil if retryable_status?(status_code)

        logger.error(body)
        Response.new(status_code, error)
      end

      # A Retry-After spends the rate-limit budget; anything else retryable
      # spends the counted backoff budget.
      def retry_delay(status_code, headers, budget)
        retry_after = parse_retry_after(headers['retry-after'])
        return budget.next_backoff_delay unless retry_after

        budget.next_rate_limit_delay(retry_after, status_code)
      end

      def configure_retries(options)
        @retries = options[:retries] || RETRIES
        @backoff_policy =
          options[:backoff_policy] || Segment::Analytics::BackoffPolicy.new
        @max_total_backoff_duration = options[:max_total_backoff_duration] ||
                                      MAX_TOTAL_BACKOFF_DURATION
        @max_rate_limit_duration    = options[:max_rate_limit_duration] ||
                                      MAX_RATE_LIMIT_DURATION
        @rate_limit_retry_after_cap = options[:rate_limit_retry_after_cap] ||
                                      RATE_LIMIT_RETRY_AFTER_CAP
      end

      def build_http(options)
        http = Net::HTTP.new(options[:host], options[:port])
        http.use_ssl = options[:ssl]
        http.read_timeout = 8
        http.open_timeout = 4
        http
      end

      def new_retry_budget
        RetryBudget.new(
          :retries => @retries,
          :backoff_policy => @backoff_policy,
          :max_total_backoff_duration => @max_total_backoff_duration,
          :max_rate_limit_duration => @max_rate_limit_duration,
          :rate_limit_retry_after_cap => @rate_limit_retry_after_cap,
          :logger => logger
        )
      end

      # nil delay means the budget is spent. Sleeping here rather than inside
      # RetryBudget keeps the wait on Transport, where callers stub it.
      def wait_to_retry(delay, budget)
        return false if delay.nil?

        sleep(delay)
        # Client#shutdown wakes this thread, so the sleep above returns early.
        return false if Thread.current[:should_exit]

        budget.record_retry
        true
      end

      def parse_error(body)
        JSON.parse(body)['error']
      rescue StandardError
        nil
      end

      def success_status?(code)
        # Spec item 1: 2xx and 3xx are success.
        code >= 200 && code < 400
      end

      def retryable_status?(code)
        if code >= 500 && code < 600
          !NON_RETRYABLE_5XX.include?(code)
        else
          RETRYABLE_4XX.include?(code)
        end
      end

      def parse_retry_after(value)
        return nil if value.nil?

        str = value.is_a?(Array) ? value.first : value
        return nil if str.nil?

        str = str.strip

        # Try integer seconds
        if str =~ /\A\d+\z/
          seconds = str.to_i
          return seconds > 0 ? seconds : nil
        end

        # Try HTTP-date (RFC 7231 S7.1.1.1)
        begin
          target = Time.httpdate(str)
          seconds = (target - Time.now).to_i
          seconds > 0 ? seconds : nil
        rescue ArgumentError
          nil
        end
      end

      # Sends a request for the batch, returns [status_code, body, headers]
      def send_request(write_key, batch, retry_count = 0)
        payload = JSON.generate(
          :sentAt => datetime_in_iso8601(Time.now),
          :batch => batch
        )
        headers = @headers.dup
        headers['X-Retry-Count'] = retry_count.to_s if retry_count > 0

        request = Net::HTTP::Post.new(@path, headers)
        request.basic_auth(write_key, nil)

        if self.class.stub
          logger.debug "stubbed request to #{@path}: " \
            "write key = #{write_key}, batch = #{JSON.generate(batch)}"

          [200, '{}', {}]
        else
          @http.start unless @http.started?
          response = @http.request(request, payload)
          [response.code.to_i, response.body, response.to_hash]
        end
      end

      class << self
        attr_writer :stub

        def stub
          @stub || ENV['STUB']
        end
      end
    end
  end
end
