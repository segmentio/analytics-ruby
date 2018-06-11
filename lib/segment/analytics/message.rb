require 'segment/analytics/defaults'

module Segment
  class Analytics
    # Represents a message to be sent to the API
    class Message
      def initialize(hash)
        @hash = hash
      end

      def too_big?
        json_size > Defaults::Message::MAX_BYTES
      end

      def json_size
        to_json.bytesize
      end

      def as_json(*args)
        @hash.as_json(*args)
      end
    end
  end
end
