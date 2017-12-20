require 'segment/analytics/defaults'
require 'segment/analytics/utils'
require 'segment/analytics/response'
require 'segment/analytics/logging'
require 'segment/analytics/backoff_policy'
require 'net/http'
require 'net/https'
require 'json'

module Segment
  class Analytics
    class Request
      include Segment::Analytics::Defaults::Request
      include Segment::Analytics::Utils
      include Segment::Analytics::Logging

      # public: Creates a new request object to send analytics batch
      #
      def initialize(options = {})
        options[:host] ||= HOST
        options[:port] ||= PORT
        options[:ssl] ||= SSL
        @headers = options[:headers] || HEADERS
        @path = options[:path] || PATH
        @retries = options[:retries] || RETRIES
        @backoff_policy =
          options[:backoff_policy] || Segment::Analytics::BackoffPolicy.new

        http = Net::HTTP.new(options[:host], options[:port])
        http.use_ssl = options[:ssl]
        http.read_timeout = 8
        http.open_timeout = 4

        @http = http
      end

      # public: Posts the write key and batch of messages to the API.
      #
      # returns - Response of the status and error if it exists
      def post(write_key, batch)
        last_response, exception = retry_with_backoff(@retries) do
          status_code, body = send_request(write_key, batch)
          error = JSON.parse(body)['error']
          should_retry = should_retry_request?(status_code, body)

          [Response.new(status_code, error), should_retry]
        end

        if exception
          logger.error(exception.message)
          exception.backtrace.each { |line| logger.error(line) }
          Response.new(-1, "Connection error: #{exception}")
        else
          last_response
        end
      end

      private

      def should_retry_request?(status_code, body)
        if status_code >= 500
          true # Server error
        elsif status_code == 429
          true # Rate limited
        elsif status_code >= 400
          logger.error(body)
          false # Client error. Do not retry, but log
        else
          false
        end
      end

      # Takes a block that returns [result, should_retry].
      #
      # Retries upto `retries_remaining` times, if `should_retry` is false or
      # an exception is raised. `@backoff_policy` is used to determine the
      # duration to sleep between attempts
      #
      # Returns [last_result, raised_exception]
      def retry_with_backoff(retries_remaining, &block)
        result, caught_exception = nil
        should_retry = false

        begin
          result, should_retry = yield
          return [result, nil] unless should_retry
        rescue StandardError => e
          should_retry = true
          caught_exception = e
        end

        if should_retry && (retries_remaining > 1)
          sleep(@backoff_policy.next_interval.to_f / 1000)
          retry_with_backoff(retries_remaining - 1, &block)
        else
          [result, caught_exception]
        end
      end

      # Sends a request for the batch, returns [status_code, body]
      def send_request(write_key, batch)
        payload = JSON.generate(
          :sentAt => datetime_in_iso8601(Time.now),
          :batch => batch
        )
        request = Net::HTTP::Post.new(@path, @headers)
        request.basic_auth(write_key, nil)

        if self.class.stub
          logger.debug "stubbed request to #{@path}: " \
            "write key = #{write_key}, batch = JSON.generate(#{batch})"

          [200, '{}']
        else
          response = @http.request(request, payload)
          [response.code.to_i, response.body]
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
