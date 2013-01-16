
require 'analytics/defaults'
require 'analytics/request'

module Analytics

  class Consumer

    def initialize(queue, secret, options = {})
      @current_batch = []
      @queue = queue
      @batch_size = options[:batch_size] || Analytics::Defaults::Queue::BATCH_SIZE
      @secret = secret
    end

    # public: Continuously runs the loop to check for new events
    def run
      while true do
        flush
      end
    end

    private

    def flush

      # Block until we have something to send
      @current_batch << @queue.pop()

      while @current_batch.length < @batch_size && !@queue.empty? do
        @current_batch << @queue.pop()
      end

      request = Analytics::Request.new
      request.post(@secret, @current_batch)
      @current_batch = []
    end


    def onError
    end

  end
end