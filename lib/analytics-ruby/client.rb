
require 'time'
require 'thread'
require 'analytics-ruby/defaults'
require 'analytics-ruby/consumer'
require 'analytics-ruby/request'

module AnalyticsRuby

  class Client

    # public: Creates a new client
    #
    # options - Hash
    #           :secret         - String of your project's secret
    #           :max_queue_size - Fixnum of the max calls to remain queued (optional)
    #           :on_error       - Proc which handles error calls from the API
    def initialize (options = {})

      @queue = Queue.new
      @secret = options[:secret]
      @max_queue_size = options[:max_queue_size] || AnalyticsRuby::Defaults::Queue::MAX_SIZE

      check_secret

      @consumer = AnalyticsRuby::Consumer.new(@queue, @secret, options)
      @thread = Thread.new { @consumer.run }
    end

    # public: Join on the thread to close
    #
    def close ()
      @consumer.close
      if @queue.length > 0
        @thread.join
      else
        @thread.join(1)
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

      event = options[:event]
      user_id = options[:user_id].to_s
      properties = options[:properties] || {}
      timestamp = options[:timestamp] || Time.new
      context = options[:context] || {}

      ensure_user(user_id)
      check_timestamp(timestamp)

      if event.nil? || event.empty?
        fail ArgumentError, 'Must supply event as a non-empty string'
      end

      add_context(context)

      enqueue({ event:      event,
                userId:     user_id,
                context:    context,
                properties: properties,
                timestamp:  timestamp.iso8601,
                action:     'track' })
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

      user_id = options[:user_id].to_s
      traits = options[:traits] || {}
      timestamp = options[:timestamp] || Time.new
      context = options[:context] || {}

      ensure_user(user_id)
      check_timestamp(timestamp)

      fail ArgumentError, 'Must supply traits as a hash' unless traits.is_a? Hash

      add_context(context)

      enqueue({ userId:    user_id,
                context:   context,
                traits:    traits,
                timestamp: timestamp.iso8601,
                action:    'identify' })
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