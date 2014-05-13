require 'thread'
require 'time'
require 'segment/analytics/utils'
require 'segment/analytics/consumer'
require 'segment/analytics/defaults'

module Segment
  class Analytics
    class Client
      include Segment::Analytics::Utils

      # public: Creates a new client
      #
      # options - Hash
      #           :write_key         - String of your project's write_key
      #           :max_queue_size - Fixnum of the max calls to remain queued (optional)
      #           :on_error       - Proc which handles error calls from the API
      def initialize options = {}
        symbolize_keys! options

        @queue = Queue.new
        @write_key = options[:write_key]
        @max_queue_size = options[:max_queue_size] || Defaults::Queue::MAX_SIZE
        @consumer = Consumer.new @queue, @write_key, options
        @thread = ConsumerThread.new { @consumer.run }

        check_write_key!

        at_exit do
          # Let the consumer thread know it should exit.
          @thread[:should_exit] = true

          # Push a flag value to the consumer queue in case it's blocked waiting for a value.  This will allow it
          # to continue its normal chain of processing, giving it a chance to exit.
          @queue << nil
        end
      end

      # public: Synchronously waits until the consumer has flushed the queue.
      #         Use only for scripts which are not long-running, and will
      #         specifically exit
      #
      def flush
        while !@queue.empty? || @consumer.is_requesting?
          sleep(0.1)
        end
      end

      # public: Tracks an event
      #
      # options - Hash
      #           :event      - String of event name.
      #           :user_id    - String of the user id.
      #           :properties - Hash of event properties. (optional)
      #           :timestamp  - Time of when the event occurred. (optional)
      #           :context    - Hash of context. (optional)
      def track options
        symbolize_keys! options
        check_user_id! options

        event = options[:event]
        properties = options[:properties] || {}
        timestamp = options[:timestamp] || Time.new
        context = options[:context] || {}

        check_timestamp! timestamp

        if event.nil? || event.empty?
          fail ArgumentError, 'Must supply event as a non-empty string'
        end

        fail ArgumentError, 'Properties must be a Hash' unless properties.is_a? Hash
        isoify_dates! properties

        add_context context

        enqueue({
          :event => event,
          :userId => options[:user_id].to_s,
          :anonymousId => options[:anonymous_id].to_s,
          :context =>  context,
          :properties => properties,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'track'
        })
      end

      # public: Identifies a user
      #
      # options - Hash
      #           :user_id   - String of the user id
      #           :traits    - Hash of user traits. (optional)
      #           :timestamp - Time of when the event occurred. (optional)
      #           :context   - Hash of context. (optional)
      def identify options
        symbolize_keys! options
        check_user_id! options

        traits = options[:traits] || {}
        timestamp = options[:timestamp] || Time.new
        context = options[:context] || {}

        check_timestamp! timestamp

        fail ArgumentError, 'Must supply traits as a hash' unless traits.is_a? Hash
        isoify_dates! traits

        add_context context

        enqueue({
          :userId => options[:user_id].to_s,
          :anonymousId => options[:anonymous_id].to_s,
          :context => context,
          :traits => traits,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'identify'
        })
      end

      # public: Aliases a user from one id to another
      #
      # options - Hash
      #           :previous_id      - String of the id to alias from
      #           :user_id        - String of the id to alias to
      #           :timestamp - Time of when the alias occured (optional)
      #           :context   - Hash of context (optional)
      def alias(options)
        symbolize_keys! options

        from = options[:previous_id].to_s
        to = options[:user_id].to_s
        timestamp = options[:timestamp] || Time.new
        context = options[:context] || {}

        check_non_empty_string! from, 'previous_id'
        check_non_empty_string! to, 'user_id'
        check_timestamp! timestamp
        add_context context

        enqueue({
          :previousId => from,
          :userId => to,
          :context => context,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'alias'
        })
      end

      # public: Associates a user identity with a group.
      #
      # options - Hash
      #           :previous_id      - String of the id to alias from
      #           :user_id        - String of the id to alias to
      #           :timestamp - Time of when the alias occured (optional)
      #           :context   - Hash of context (optional)
      def group(options)
        symbolize_keys! options
        check_user_id! options

        group_id = options[:group_id].to_s
        user_id = options[:user_id].to_s
        traits = options[:traits] || {}
        timestamp = options[:timestamp] || Time.new
        context = options[:context] || {}

        fail ArgumentError, '.traits must be a hash' unless traits.is_a? Hash

        check_non_empty_string! group_id, 'group_id'
        check_timestamp! timestamp
        add_context context

        enqueue({
          :groupId => group_id,
          :userId => user_id,
          :traits => traits,
          :context => context,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'group'
        })
      end

      # public: Records a page view
      #
      # options - Hash
      #           :user_id    - String of the id to alias from
      #           :name       - String name of the page
      #           :properties - Hash of page properties (optional)
      #           :timestamp  - Time of when the pageview occured (optional)
      #           :context    - Hash of context (optional)
      def page(options)
        symbolize_keys! options
        check_user_id! options

        name = options[:name].to_s
        properties = options[:properties] || {}
        timestamp = options[:timestamp] || Time.new
        context = options[:context] || {}

        fail ArgumentError, '.name must be a string' unless !name.empty?
        fail ArgumentError, '.properties must be a hash' unless properties.is_a? Hash
        isoify_dates! properties

        check_timestamp! timestamp
        add_context context

        enqueue({
          :userId => options[:user_id].to_s,
          :anonymousId => options[:anonymous_id].to_s,
          :name => name,
          :properties => properties,
          :context => context,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'page'
        })
      end
      # public: Records a screen view (for a mobile app)
      #
      # options - Hash
      #           :user_id    - String of the id to alias from
      #           :name       - String name of the screen
      #           :properties - Hash of screen properties (optional)
      #           :timestamp  - Time of when the screen occured (optional)
      #           :context    - Hash of context (optional)
      def screen(options)
        symbolize_keys! options
        check_user_id! options

        name = options[:name].to_s
        properties = options[:properties] || {}
        timestamp = options[:timestamp] || Time.new
        context = options[:context] || {}

        fail ArgumentError, '.name must be a string' if name.empty?
        fail ArgumentError, '.properties must be a hash' unless properties.is_a? Hash
        isoify_dates! properties

        check_timestamp! timestamp
        add_context context

        enqueue({
          :userId => options[:user_id].to_s,
          :anonymousId => options[:anonymous_id].to_s,
          :name => name,
          :properties => properties,
          :context => context,
          :timestamp => timestamp.iso8601,
          :type => 'screen'
        })
      end

      # public: Returns the number of queued messages
      #
      # returns Fixnum of messages in the queue
      def queued_messages
        @queue.length
      end

      private

      # private: Enqueues the action.
      #
      # returns Boolean of whether the item was added to the queue.
      def enqueue(action)
        # add our request id for tracing purposes
        action[:messageId] = uid

        queue_full = @queue.length >= @max_queue_size
        @queue << action unless queue_full

        !queue_full
      end

      # private: Ensures that a string is non-empty
      #
      # str    - String that must be non-empty
      # name   - Name of the validated value
      #
      def check_non_empty_string!(str, name)
        fail ArgumentError, "Must supply a non-empty #{name}" if str.empty?
      end

      # private: Adds contextual information to the call
      #
      # context - Hash of call context
      def add_context(context)
        context[:library] =  { :name => "analytics-ruby", :version => Segment::Analytics::VERSION.to_s }
      end

      # private: Checks that the write_key is properly initialized
      def check_write_key!
        fail ArgumentError, 'Write key must be initialized' if @write_key.nil?
      end

      # private: Checks the timstamp option to make sure it is a Time.
      def check_timestamp!(timestamp)
        fail ArgumentError, 'Timestamp must be a Time' unless timestamp.is_a? Time
      end

      def event attrs
        symbolize_keys! attrs

        {
          :userId => user_id,
          :name => name,
          :properties => properties,
          :context => context,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'screen'
        }
      end

      def check_user_id! options
        fail ArgumentError, 'Must supply either user_id or anonymous_id' unless options[:user_id] || options[:anonymous_id]
      end

      # Sub-class thread so we have a named thread (useful for debugging in Thread.list).
      class ConsumerThread < Thread
      end
    end
  end
end

