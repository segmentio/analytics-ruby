require 'forwardable'
require 'segment/analytics/logging'

module Segment
  class Analytics
    # A batch of `Message`s to be sent to the API
    class MessageBatch
      class JSONGenerationError < StandardError; end

      extend Forwardable
      include Segment::Analytics::Logging
      include Segment::Analytics::Defaults::MessageBatch

      def initialize(max_message_count)
        @messages = []
        @max_message_count = max_message_count
        @json_size = 0
      end

      def <<(message)
        begin
          message_json = message.to_json
        rescue StandardError => e
          raise JSONGenerationError, "Serialization error: #{e}"
        end

        message_json_size = message_json.bytesize
        if message_too_big?(message_json_size)
          logger.error('a message exceeded the maximum allowed size')
        else
          @messages << message
          @json_size += message_json_size + 1 # One byte for the comma
        end
      end

      def full?
        item_count_exhausted? || size_exhausted?
      end

      def clear
        @messages.clear
        @json_size = 0
      end

      def_delegators :@messages, :to_json
      def_delegators :@messages, :empty?
      def_delegators :@messages, :length

      private

      def item_count_exhausted?
        @messages.length >= @max_message_count
      end

      def message_too_big?(message_json_size)
        message_json_size > Defaults::Message::MAX_BYTES
      end

      # We consider the max size here as just enough to leave room for one more
      # message of the largest size possible. This is a shortcut that allows us
      # to use a native Ruby `Queue` that doesn't allow peeking. The tradeoff
      # here is that we might fit in less messages than possible into a batch.
      #
      # The alternative is to use our own `Queue` implementation that allows
      # peeking, and to consider the next message size when calculating whether
      # the message can be accomodated in this batch.
      def size_exhausted?
        @json_size >= (MAX_BYTES - Defaults::Message::MAX_BYTES)
      end
    end
  end
end
