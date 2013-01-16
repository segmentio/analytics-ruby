
require 'analytics/defaults'
require 'analytics/request'

module Analytics

  class Consumer

    # public: Creates a new consumer
    #
    # The consumer continuously takes messages off the queue
    # and makes requests to the segment.io api
    #
    def initialize(queue, secret, options = {})
      @current_batch = []
      @queue = queue
      @batch_size = options[:batch_size] || Analytics::Defaults::Queue::BATCH_SIZE
      @secret = secret
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
      res = req.post(@secret, @current_batch)

      onError(res) unless res.status == 200

      @current_batch = []
    end

    # private: Error handler whenever the api does not
    #          return a valid response
    def onError(res)
      puts res.status
      puts res.body
    end

  end
end