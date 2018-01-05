module Segment
  class Analytics
    # A batch of `Message`s to be sent to the API
    class MessageBatch
      extend Forwardable

      def initialize
        @messages = []
      end

      def_delegators :@messages, :to_json # TODO: Cache and reuse
      def_delegators :@messages, :<<
      def_delegators :@messages, :clear
      def_delegators :@messages, :empty?
      def_delegators :@messages, :length
    end
  end
end
