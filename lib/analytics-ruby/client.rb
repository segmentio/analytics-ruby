
require 'time'
require 'thread'
require 'analytics-ruby/defaults'
require 'analytics-ruby/consumer'
require 'analytics-ruby/request'
require 'analytics-ruby/util'

module AnalyticsRuby

  class Client

    # Sub-class thread so we have a named thread (useful for debugging in Thread.list).
    class ConsumerThread < Thread
    end

    # public: Creates a new client
    #
    # options - Hash
    #           :secret         - String of your project's secret
    #           :max_queue_size - Fixnum of the max calls to remain queued (optional)
    #           :on_error       - Proc which handles error calls from the API
    def initialize(options = {})

      Util.symbolize_keys! options

      @queue = Queue.new
      @secret = options[:secret]
      @max_queue_size = options[:max_queue_size] || Defaults::Queue::MAX_SIZE

      check_secret

      @consumer = Consumer.new @queue, @secret, options
      @thread = ConsumerThread.new { @consumer.run }

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
    def track(options)

      check_secret

      Util.symbolize_keys! options

      event = options[:event]
      user_id = options[:user_id].to_s
      properties = options[:properties] || {}
      timestamp = options[:timestamp] || Time.new
      context = options[:context] || {}

      ensure_user user_id
      check_timestamp timestamp

      if event.nil? || event.empty?
        fail ArgumentError, 'Must supply event as a non-empty string'
      end

      fail ArgumentError, 'Properties must be a Hash' unless properties.is_a? Hash
      Util.isoify_dates! properties

      add_context context

      enqueue({
        :event => event,
        :userId => user_id,
        :context =>  context,
        :properties => properties,
        :timestamp => timestamp.iso8601,
        :action => 'track'
      })
    end

    # public: Identifies a user
    #
    # options - Hash
    #           :user_id   - String of the user id
    #           :traits    - Hash of user traits. (optional)
    #           :timestamp - Time of when the event occurred. (optional)
    #           :context   - Hash of context. (optional)
    def identify(options)

      check_secret

      Util.symbolize_keys! options

      user_id = options[:user_id].to_s
      traits = options[:traits] || {}
      timestamp = options[:timestamp] || Time.new
      context = options[:context] || {}

      ensure_user user_id
      check_timestamp timestamp

      fail ArgumentError, 'Must supply traits as a hash' unless traits.is_a? Hash
      Util.isoify_dates! traits

      add_context context

      enqueue({
        :userId => user_id,
        :context => context,
        :traits => traits,
        :timestamp => timestamp.iso8601,
        :action => 'identify'
      })
    end

    # public: Aliases a user from one id to another
    #
    # options - Hash
    #           :from      - String of the id to alias from
    #           :to        - String of the id to alias to
    #           :timestamp - Time of when the alias occured (optional)
    #           :context   - Hash of context (optional)
    def alias(options)
      check_secret
      Util.symbolize_keys! options
      from = options[:from].to_s
      to = options[:to].to_s
      timestamp = options[:timestamp] || Time.new
      context = options[:context] || {}

      ensure_user from
      ensure_user to
      check_timestamp timestamp
      add_context context

      enqueue({
        :from => from,
        :to => to,
        :context => context,
        :timestamp => timestamp.iso8601,
        :action => 'alias'
      })
    end

    # public: Associates a user identity with a group.
    #
    # options - Hash
    #           :from      - String of the id to alias from
    #           :to        - String of the id to alias to
    #           :timestamp - Time of when the alias occured (optional)
    #           :context   - Hash of context (optional)
    def group(options)
      check_secret
      Util.symbolize_keys! options
      group_id = options[:group_id].to_s
      user_id = options[:user_id].to_s
      traits = options[:traits] || {}
      timestamp = options[:timestamp] || Time.new
      context = options[:context] || {}

      fail ArgumentError, '.traits must be a hash' unless traits.is_a? Hash

      ensure_user group_id
      ensure_user user_id
      check_timestamp timestamp
      add_context context

      enqueue({
        :groupId => group_id,
        :userId => user_id,
        :traits => traits,
        :context => context,
        :timestamp => timestamp.iso8601,
        :action => 'group'
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
      check_secret
      Util.symbolize_keys! options
      user_id = options[:user_id].to_s
      name = options[:name].to_s
      properties = options[:properties] || {}
      timestamp = options[:timestamp] || Time.new
      context = options[:context] || {}

      fail ArgumentError, '.name must be a string' unless !name.empty?
      fail ArgumentError, '.properties must be a hash' unless properties.is_a? Hash
      Util.isoify_dates! properties

      ensure_user user_id
      check_timestamp timestamp
      add_context context

      enqueue({
        :userId => user_id,
        :name => name,
        :properties => properties,
        :context => context,
        :timestamp => timestamp.iso8601,
        :action => 'page'
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
      check_secret
      Util.symbolize_keys! options
      user_id = options[:user_id].to_s
      name = options[:name].to_s
      properties = options[:properties] || {}
      timestamp = options[:timestamp] || Time.new
      context = options[:context] || {}

      fail ArgumentError, '.name must be a string' if name.empty?
      fail ArgumentError, '.properties must be a hash' unless properties.is_a? Hash
      Util.isoify_dates! properties

      ensure_user user_id
      check_timestamp timestamp
      add_context context

      enqueue({
        :userId => user_id,
        :name => name,
        :properties => properties,
        :context => context,
        :timestamp => timestamp.iso8601,
        :action => 'screen'
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
      action[:requestId] = Util.uid

      queue_full = @queue.length >= @max_queue_size
      @queue << action unless queue_full

      !queue_full
    end

    # private: Ensures that a user id was passed in.
    #
    # user_id    - String of the user id
    #
    def ensure_user(user_id)
      fail ArgumentError, 'Must supply a non-empty user_id' if user_id.empty?
    end

    # private: Adds contextual information to the call
    #
    # context - Hash of call context
    def add_context(context)
      context[:library] = 'analytics-ruby'
    end

    # private: Checks that the secret is properly initialized
    def check_secret
      fail 'Secret must be initialized' if @secret.nil?
    end

    # private: Checks the timstamp option to make sure it is a Time.
    def check_timestamp(timestamp)
      fail ArgumentError, 'Timestamp must be a Time' unless timestamp.is_a? Time
    end
  end
end