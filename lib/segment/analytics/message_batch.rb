require 'segment/analytics/logging'

module Segment
  class Analytics
    # A batch of `Message`s to be sent to the API
    class MessageBatch
      extend Forwardable
      include Segment::Analytics::Logging

      def initialize
        @messages = []
      end

      def <<(message)
        if message.too_big?
          logger.error('a message exceeded the maximum allowed size')
        else
          @messages << message
        end
      end

      def_delegators :@messages, :to_json # TODO: Cache and reuse
      def_delegators :@messages, :clear
      def_delegators :@messages, :empty?
      def_delegators :@messages, :length
    end
  end
end
