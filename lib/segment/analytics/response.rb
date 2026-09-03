# frozen_string_literal: true

module Segment
  class Analytics
    class Response
      attr_reader :status, :error

      # public: Simple class to wrap responses from the API
      #
      #
      def initialize(status = 200, error = nil)
        @status = status
        @error  = error
      end

      def success?
        # Spec item 1: 2xx and 3xx are success.
        status >= 200 && status < 400
      end
    end
  end
end
