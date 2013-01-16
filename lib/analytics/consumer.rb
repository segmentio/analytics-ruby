
require 'analytics/defaults'
require 'analytics/request'

module Analytics

  class Consumer

    # public: Creates a new consumer
    #
    # The consumer continuously takes messages off the queue
    # and makes requests to the segment.io api
    #
    # queue   - Queue synchronized between client and consumer
    # secret  - String of the project's secret
    # options - Hash of consumer options
    #           batch_size - Fixnum of how many items to send in a batch
    #           on_error   - Proc of what to do on an error
    #
    def initialize(queue, secret, options = {})
      @queue = queue
      @secret = secret
      @batch_size = options[:batch_size] || Analytics::Defaults::Queue::BATCH_SIZE
      @on_error = options[:on_error] || Proc.new { |status, error| }

      @current_batch = []
    end

    # public: Continuously runs the loop to check for new events
    #
    def run
      while true
        flush
      end
    end

    private

    # private: Flush some events from our queue
    #
    def flush

      # Block until we have something to send
      @current_batch << @queue.pop()

      until @current_batch.length >= @batch_size || @queue.empty?
        @current_batch << @queue.pop()
      end

      req = Analytics::Request.new

      begin
        res = req.post(@secret, @current_batch)
        @on_error.call(res.status, res.body["error"]) unless res.status == 200
      rescue Exception => msg
        @on_error.call(-1, "Connection error: #{msg}")
      end

      @current_batch = []
    end

  end
end