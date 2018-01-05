require 'forwardable'

module Segment
  class Analytics
    # Represents a message to be sent to the API
    class Message
      extend Forwardable

      def initialize(hash)
        @hash = hash
      end

      def_delegators :@hash, :to_json # TODO: Cache and reuse
      def_delegators :@hash, :[]
    end
  end
end
