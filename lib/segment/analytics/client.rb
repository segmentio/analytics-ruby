require 'thread'
require 'time'

require 'segment/analytics/defaults'
require 'segment/analytics/logging'
require 'segment/analytics/utils'
require 'segment/analytics/worker'

module Segment
  class Analytics
    class Client
      include Segment::Analytics::Utils
      include Segment::Analytics::Logging

      # @param [Hash] opts
      # @option opts [String] :write_key Your project's write_key
      # @option opts [FixNum] :max_queue_size Maximum number of calls to be
      #   remain queued.
      # @option opts [Proc] :on_error Handles error calls from the API.
      def initialize(opts = {})
        symbolize_keys!(opts)

        @queue = Queue.new
        @write_key = opts[:write_key]
        @max_queue_size = opts[:max_queue_size] || Defaults::Queue::MAX_SIZE
        @worker_mutex = Mutex.new
        @worker = Worker.new(@queue, @write_key, opts)

        check_write_key!

        at_exit { @worker_thread && @worker_thread[:should_exit] = true }
      end

      # Synchronously waits until the worker has flushed the queue.
      #
      # Use only for scripts which are not long-running, and will specifically
      # exit
      def flush
        while !@queue.empty? || @worker.is_requesting?
          ensure_worker_running
          sleep(0.1)
        end
      end

      # Tracks an event
      #
      # @see https://segment.com/docs/sources/server/ruby/#track
      #
      # @param [Hash] attrs
      # @option attrs [String] :anonymous_id ID for a user when you don't know
      #   who they are yet. (optional but you must provide either an
      #   `anonymous_id` or `user_id`)
      # @option attrs [Hash] :context ({})
      # @option attrs [String] :event Event name
      # @option attrs [Hash] :integrations What integrations this event
      #   goes to (optional)
      # @option attrs [Hash] :options Options such as user traits (optional)
      # @option attrs [Hash] :properties Event properties (optional)
      # @option attrs [Time] :timestamp When the event occurred (optional)
      # @option attrs [String] :user_id The ID for this user in your database
      #   (optional but you must provide either an `anonymous_id` or `user_id`)
      # @option attrs [String] :message_id ID that uniquely
      #   identifies a message across the API. (optional)
      def track(attrs)
        symbolize_keys! attrs
        check_user_id! attrs

        event = attrs[:event]
        properties = attrs[:properties] || {}
        timestamp = attrs[:timestamp] || Time.new
        context = attrs[:context] || {}
        message_id = attrs[:message_id].to_s if attrs[:message_id]

        check_timestamp! timestamp

        if event.nil? || event.empty?
          raise ArgumentError, 'Must supply event as a non-empty string'
        end

        raise ArgumentError, 'Properties must be a Hash' unless properties.is_a? Hash
        isoify_dates! properties

        add_context context

        enqueue({
          :event => event,
          :userId => attrs[:user_id],
          :anonymousId => attrs[:anonymous_id],
          :context => context,
          :options => attrs[:options],
          :integrations => attrs[:integrations],
          :properties => properties,
          :messageId => message_id,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'track'
        })
      end

      # Identifies a user
      #
      # @see https://segment.com/docs/sources/server/ruby/#identify
      #
      # @param [Hash] attrs
      # @option attrs [String] :anonymous_id ID for a user when you don't know
      #   who they are yet. (optional but you must provide either an
      #   `anonymous_id` or `user_id`)
      # @option attrs [Hash] :context ({})
      # @option attrs [Hash] :integrations What integrations this event
      #   goes to (optional)
      # @option attrs [Hash] :options Options such as user traits (optional)
      # @option attrs [Time] :timestamp When the event occurred (optional)
      # @option attrs [Hash] :traits User traits (optional)
      # @option attrs [String] :user_id The ID for this user in your database
      #   (optional but you must provide either an `anonymous_id` or `user_id`)
      # @option attrs [String] :message_id ID that uniquely identifies a
      #   message across the API. (optional)
      def identify(attrs)
        symbolize_keys! attrs
        check_user_id! attrs

        traits = attrs[:traits] || {}
        timestamp = attrs[:timestamp] || Time.new
        context = attrs[:context] || {}
        message_id = attrs[:message_id].to_s if attrs[:message_id]

        check_timestamp! timestamp

        raise ArgumentError, 'Must supply traits as a hash' unless traits.is_a? Hash
        isoify_dates! traits

        add_context context

        enqueue({
          :userId => attrs[:user_id],
          :anonymousId => attrs[:anonymous_id],
          :integrations => attrs[:integrations],
          :context => context,
          :traits => traits,
          :options => attrs[:options],
          :messageId => message_id,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'identify'
        })
      end

      # Aliases a user from one id to another
      #
      # @see https://segment.com/docs/sources/server/ruby/#alias
      #
      # @param [Hash] attrs
      # @option attrs [Hash] :context ({})
      # @option attrs [Hash] :integrations What integrations this must be
      #   sent to (optional)
      # @option attrs [Hash] :options Options such as user traits (optional)
      # @option attrs [String] :previous_id The ID to alias from
      # @option attrs [Time] :timestamp When the alias occurred (optional)
      # @option attrs [String] :user_id The ID to alias to
      # @option attrs [String] :message_id ID that uniquely identifies a
      #   message across the API. (optional)
      def alias(attrs)
        symbolize_keys! attrs

        from = attrs[:previous_id]
        to = attrs[:user_id]
        timestamp = attrs[:timestamp] || Time.new
        context = attrs[:context] || {}
        message_id = attrs[:message_id].to_s if attrs[:message_id]

        check_presence! from, 'previous_id'
        check_presence! to, 'user_id'
        check_timestamp! timestamp
        add_context context

        enqueue({
          :previousId => from,
          :userId => to,
          :integrations => attrs[:integrations],
          :context => context,
          :options => attrs[:options],
          :messageId => message_id,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'alias'
        })
      end

      # Associates a user identity with a group.
      #
      # @see https://segment.com/docs/sources/server/ruby/#group
      #
      # @param [Hash] attrs
      # @option attrs [String] :anonymous_id ID for a user when you don't know
      #   who they are yet. (optional but you must provide either an
      #   `anonymous_id` or `user_id`)
      # @option attrs [Hash] :context ({})
      # @option attrs [String] :group_id The ID of the group
      # @option attrs [Hash] :integrations What integrations this event
      #   goes to (optional)
      # @option attrs [Hash] :options Options such as user traits (optional)
      # @option attrs [Time] :timestamp When the event occurred (optional)
      # @option attrs [String] :user_id The ID for the user that is part of
      #   the group
      # @option attrs [String] :message_id ID that uniquely identifies a
      #   message across the API. (optional)
      def group(attrs)
        symbolize_keys! attrs
        check_user_id! attrs

        group_id = attrs[:group_id]
        user_id = attrs[:user_id]
        traits = attrs[:traits] || {}
        timestamp = attrs[:timestamp] || Time.new
        context = attrs[:context] || {}
        message_id = attrs[:message_id].to_s if attrs[:message_id]

        raise ArgumentError, '.traits must be a hash' unless traits.is_a? Hash
        isoify_dates! traits

        check_presence! group_id, 'group_id'
        check_timestamp! timestamp
        add_context context

        enqueue({
          :groupId => group_id,
          :userId => user_id,
          :traits => traits,
          :integrations => attrs[:integrations],
          :options => attrs[:options],
          :context => context,
          :messageId => message_id,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'group'
        })
      end

      # Records a page view
      #
      # @see https://segment.com/docs/sources/server/ruby/#page
      #
      # @param [Hash] attrs
      # @option attrs [String] :anonymous_id ID for a user when you don't know
      #   who they are yet. (optional but you must provide either an
      #   `anonymous_id` or `user_id`)
      # @option attrs [String] :category The page category (optional)
      # @option attrs [Hash] :context ({})
      # @option attrs [Hash] :integrations What integrations this event
      #   goes to (optional)
      # @option attrs [String] :name Name of the page
      # @option attrs [Hash] :options Options such as user traits (optional)
      # @option attrs [Hash] :properties Page properties (optional)
      # @option attrs [Time] :timestamp When the pageview occurred (optional)
      # @option attrs [String] :user_id The ID of the user viewing the page
      # @option attrs [String] :message_id ID that uniquely identifies a
      #   message across the API. (optional)
      def page(attrs)
        symbolize_keys! attrs
        check_user_id! attrs

        name = attrs[:name].to_s
        properties = attrs[:properties] || {}
        timestamp = attrs[:timestamp] || Time.new
        context = attrs[:context] || {}
        message_id = attrs[:message_id].to_s if attrs[:message_id]

        raise ArgumentError, '.properties must be a hash' unless properties.is_a? Hash
        isoify_dates! properties

        check_timestamp! timestamp
        add_context context

        enqueue({
          :userId => attrs[:user_id],
          :anonymousId => attrs[:anonymous_id],
          :name => name,
          :category => attrs[:category],
          :properties => properties,
          :integrations => attrs[:integrations],
          :options => attrs[:options],
          :context => context,
          :messageId => message_id,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'page'
        })
      end

      # Records a screen view (for a mobile app)
      #
      # @param [Hash] attrs
      # @option attrs [String] :anonymous_id ID for a user when you don't know
      #   who they are yet. (optional but you must provide either an
      #   `anonymous_id` or `user_id`)
      # @option attrs [String] :category The screen category (optional)
      # @option attrs [Hash] :context ({})
      # @option attrs [Hash] :integrations What integrations this event
      #   goes to (optional)
      # @option attrs [String] :name Name of the screen
      # @option attrs [Hash] :options Options such as user traits (optional)
      # @option attrs [Hash] :properties Page properties (optional)
      # @option attrs [Time] :timestamp When the pageview occurred (optional)
      # @option attrs [String] :user_id The ID of the user viewing the screen
      # @option attrs [String] :message_id ID that uniquely identifies a
      #   message across the API. (optional)
      def screen(attrs)
        symbolize_keys! attrs
        check_user_id! attrs

        name = attrs[:name].to_s
        properties = attrs[:properties] || {}
        timestamp = attrs[:timestamp] || Time.new
        context = attrs[:context] || {}
        message_id = attrs[:message_id].to_s if attrs[:message_id]

        raise ArgumentError, '.properties must be a hash' unless properties.is_a? Hash
        isoify_dates! properties

        check_timestamp! timestamp
        add_context context

        enqueue({
          :userId => attrs[:user_id],
          :anonymousId => attrs[:anonymous_id],
          :name => name,
          :properties => properties,
          :category => attrs[:category],
          :options => attrs[:options],
          :integrations => attrs[:integrations],
          :context => context,
          :messageId => message_id,
          :timestamp => timestamp.iso8601,
          :type => 'screen'
        })
      end

      # @return [Fixnum] number of messages in the queue
      def queued_messages
        @queue.length
      end

      private

      # private: Enqueues the action.
      #
      # returns Boolean of whether the item was added to the queue.
      def enqueue(action)
        # add our request id for tracing purposes
        action[:messageId] ||= uid

        if @queue.length < @max_queue_size
          @queue << action
          ensure_worker_running

          true
        else
          logger.warn(
            'Queue is full, dropping events. The :max_queue_size ' \
            'configuration parameter can be increased to prevent this from ' \
            'happening.'
          )
          false
        end
      end

      # private: Ensures that a string is non-empty
      #
      # obj    - String|Number that must be non-blank
      # name   - Name of the validated value
      #
      def check_presence!(obj, name)
        if obj.nil? || (obj.is_a?(String) && obj.empty?)
          raise ArgumentError, "#{name} must be given"
        end
      end

      # private: Adds contextual information to the call
      #
      # context - Hash of call context
      def add_context(context)
        context[:library] = { :name => 'analytics-ruby', :version => Segment::Analytics::VERSION.to_s }
      end

      # private: Checks that the write_key is properly initialized
      def check_write_key!
        raise ArgumentError, 'Write key must be initialized' if @write_key.nil?
      end

      # private: Checks the timstamp option to make sure it is a Time.
      def check_timestamp!(timestamp)
        raise ArgumentError, 'Timestamp must be a Time' unless timestamp.is_a? Time
      end

      def check_user_id!(attrs)
        unless attrs[:user_id] || attrs[:anonymous_id]
          raise ArgumentError, 'Must supply either user_id or anonymous_id'
        end
      end

      def ensure_worker_running
        return if worker_running?
        @worker_mutex.synchronize do
          return if worker_running?
          @worker_thread = Thread.new do
            @worker.run
          end
        end
      end

      def worker_running?
        @worker_thread && @worker_thread.alive?
      end
    end
  end
end
