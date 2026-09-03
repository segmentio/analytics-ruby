# frozen_string_literal: true

require 'segment/analytics/defaults'
require 'segment/analytics/utils'
require 'segment/analytics/response'
require 'segment/analytics/logging'
require 'segment/analytics/backoff_policy'
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
        @retries = options[:retries] || RETRIES
        @backoff_policy =
          options[:backoff_policy] || Segment::Analytics::BackoffPolicy.new

        @max_total_backoff_duration = options[:max_total_backoff_duration] ||
                                      MAX_TOTAL_BACKOFF_DURATION
        @max_rate_limit_duration    = options[:max_rate_limit_duration] ||
                                      MAX_RATE_LIMIT_DURATION
        @rate_limit_retry_after_cap = options[:rate_limit_retry_after_cap] ||
                                      RATE_LIMIT_RETRY_AFTER_CAP

        http = Net::HTTP.new(options[:host], options[:port])
        http.use_ssl = options[:ssl]
        http.read_timeout = 8
        http.open_timeout = 4

        @http = http
      end

      # Sends a batch of messages to the API
      #
      # @return [Response] API response
      def send(write_key, batch)
        logger.debug("Sending request for #{batch.length} items")

        @backoff_policy.reset! if @backoff_policy.respond_to?(:reset!)

        retry_count           = 0
        retries_remaining     = @retries
        backoff_start_time    = nil
        rate_limit_start_time = nil

        # Returns a Response when the batch should be abandoned, or nil to retry.
        consume_backoff = lambda do |response_error, response_status|
          retries_remaining -= 1
          if retries_remaining <= 0
            logger.error('Retries exhausted for batch')
            next Response.new(response_status, response_error)
          end

          backoff_start_time ||= Time.now
          if (Time.now - backoff_start_time) >= @max_total_backoff_duration
            logger.error('Max total backoff duration exceeded for batch')
            next Response.new(response_status, response_error)
          end

          delay_ms = @backoff_policy.next_interval
          logger.debug("Retrying request, #{retries_remaining} retries left. Waiting #{delay_ms}ms")
          sleep(delay_ms.to_f / 1000)
          next Response.new(response_status, response_error) if Thread.current[:should_exit]

          retry_count += 1
          nil
        end

        loop do
          begin
            status_code, body, response_headers = send_request(write_key, batch, retry_count)
          rescue StandardError => e
            # Connection reset, DNS failure, read timeout and friends. These were
            # retried before this branch was refactored; they still are, on the
            # counted backoff budget rather than for free.
            logger.error("Network error: #{e.message}")
            give_up = consume_backoff.call(e.to_s, -1)
            return give_up if give_up

            next
          end

          error = begin
            JSON.parse(body)['error']
          rescue StandardError
            nil
          end
          logger.debug("Response status code: #{status_code}")
          logger.debug("Response error: #{error}") if error

          return Response.new(status_code, error) if success_status?(status_code)

          unless retryable_status?(status_code)
            logger.error(body)
            return Response.new(status_code, error)
          end

          # Any retryable status with Retry-After: use rate-limit path (no retry budget cost)
          retry_after = parse_retry_after(response_headers['retry-after'])
          if retry_after
            rate_limit_start_time ||= Time.now
            if (Time.now - rate_limit_start_time) >= @max_rate_limit_duration
              logger.error('Max rate limit duration exceeded for batch')
              return Response.new(status_code, error)
            end
            delay = [retry_after, @rate_limit_retry_after_cap].min
            logger.debug("Retry-After: #{delay}s on #{status_code}. Retrying after delay.")
            sleep(delay)
            # Client#shutdown wakes this thread, so the sleep above returns early.
            return Response.new(status_code, error) if Thread.current[:should_exit]

            retry_count += 1
            next
          end

          # No Retry-After: counted backoff
          give_up = consume_backoff.call(error, status_code)
          return give_up if give_up
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
          return seconds > 0 ? seconds : nil
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
