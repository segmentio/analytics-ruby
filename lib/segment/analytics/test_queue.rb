module Segment
  class Analytics
    class TestQueue
      attr_reader :messages

      def initialize
        reset!
      end

      def [](key)
        all[key]
      end

      def count
        all.count
      end

      def <<(message)
        all << message
        send(message[:type]) << message
      end

      def alias
        messages[:alias] ||= []
      end

      def all
        messages[:all] ||= []
      end

      def group
        messages[:group] ||= []
      end

      def identify
        messages[:identify] ||= []
      end

      def page
        messages[:page] ||= []
      end

      def screen
        messages[:screen] ||= []
      end

      def track
        messages[:track] ||= []
      end

      def reset!
        @messages = {}
      end
    end
  end
end
