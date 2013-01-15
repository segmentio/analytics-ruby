
require 'time'
require 'thread'
require 'analytics/consumer'
require 'analytics/request'

module Analytics

  class Client

    def initialize (options)
      @secret = options[:secret]
      @queue = Queue.new
      Thread.new {
        puts "Starting new thread!"
        @consumer = Analytics::Consumer.new(@queue, @secret)
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

      puts "Adding track"

      @queue << { event:      event,
                  sessionId:  session_id,
                  userId:     user_id,
                  context:    context,
                  properties: properties,
                  timestamp:  timestamp.iso8601,
                  action:     "track" }
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

      puts "Adding identify"

      @queue << { sessionId: session_id,
                  userId:    user_id,
                  context:   context,
                  traits:    traits,
                  timestamp: timestamp.iso8601,
                  action:    "identify" }
    end


    private

    # Private: ensures that a user id was passed in
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

    def add_context(context)
      context[:library] = "analytics-ruby"
    end

    def check_secret
      fail "Secret must be initialized" if @secret.nil?
    end

    def check_timestamp(timestamp)
      fail ArgumentError, "Timestamp must be a Time" unless timestamp.is_a? Time
    end
  end
end