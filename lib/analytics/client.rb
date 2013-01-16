
require 'time'
require 'thread'
require 'analytics/defaults'
require 'analytics/consumer'
require 'analytics/request'

module Analytics

  class Client

    # Public: Creates a new client
    #
    # options - Hash
    #           :secret         - String of your project's secret
    #           :max_queue_size - Fixnum of the max calls to remain queued (optional)
    def initialize (options = {})

      @queue = Queue.new
      @secret = options[:secret]
      @max_queue_size = options[:max_queue_size] || Analytics::Defaults::Queue::MAX_SIZE

      check_secret

      Thread.new {
        @consumer = Analytics::Consumer.new(@queue, @secret, options)
        @consumer.run
      }
    end

    # Public: Tracks an event
    #
    # options - Hash
    #           :event      - String of event name.
    #           :sessionId  - String of the user session. (optional with userId)
    #           :userId     - String of the user id. (optional with sessionId)
    #           :context    - Hash of context. (optional)
    #           :properties - Hash of event properties. (optional)
    #           :timestamp  - Time of when the event occurred. (optional)
    def track(options)

      check_secret

      event = options[:event]
      session_id = options[:session_id]
      user_id = options[:user_id]
      context = options[:context] || {}
      properties = options[:properties] || {}
      timestamp = options[:timestamp] || Time.new

      ensure_user(session_id, user_id)
      check_timestamp(timestamp)

      if event.nil? || event.empty?
        fail ArgumentError, "Must supply event as a non-empty string"
      end

      add_context(context)

      enqueue({ event:      event,
                sessionId:  session_id,
                userId:     user_id,
                context:    context,
                properties: properties,
                timestamp:  timestamp.iso8601,
                action:     "track" })
    end

    # Public: Identifies a user
    #
    # options - Hash
    #           :sessionId - String of the user session. (optional with userId)
    #           :userId    - String of the user id. (optional with sessionId)
    #           :context   - Hash of context. (optional)
    #           :traits    - Hash of user traits. (optional)
    #           :timestamp - Time of when the event occurred. (optional)
    def identify(options)

      check_secret

      session_id = options[:session_id]
      user_id = options[:user_id]
      context = options[:context] || {}
      traits = options[:traits] || {}
      timestamp = options[:timestamp] || Time.new

      ensure_user(session_id, user_id)
      check_timestamp(timestamp)

      fail ArgumentError, "Must supply traits as a hash" unless traits.is_a? Hash

      add_context(context)

      enqueue({ sessionId: session_id,
                userId:    user_id,
                context:   context,
                traits:    traits,
                timestamp: timestamp.iso8601,
                action:    "identify" })
    end


    private

    # Private: Enqueues the action.
    #
    # returns Boolean of whether the item was added to the queue.
    def enqueue(action)
      remaining_space = @queue.length < @max_queue_size
      @queue << action if remaining_space

      remaining_space
    end

    # Private: Ensures that a user id was passed in.
    #
    # session_id - String of the session
    # user_id    - String of the user id
    #
    def ensure_user(session_id, user_id)
      message = "Must supply either a non-empty session_id or user_id (or both)"

      valid = user_id.is_a?(String) && !user_id.empty?
      valid ||= session_id.is_a?(String) && !session_id.empty?

      fail ArgumentError, message unless valid
    end

    # Private: Adds contextual information to the call
    #
    # context - Hash of call context
    def add_context(context)
      context[:library] = "analytics-ruby"
    end

    # Private: Checks that the secret is properly initialized
    def check_secret
      fail "Secret must be initialized" if @secret.nil?
    end

    # Private: Checks the timstamp option to make sure it is a Time.
    def check_timestamp(timestamp)
      fail ArgumentError, "Timestamp must be a Time" unless timestamp.is_a? Time
    end
  end
end