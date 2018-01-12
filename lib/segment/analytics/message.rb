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

      # Since the hash is expected to not be modified (set at initialization),
      # the JSON version can be cached after the first computation.
      def to_json(*args)
        @json ||= @hash.to_json(*args)
      end
    end
  end
end
