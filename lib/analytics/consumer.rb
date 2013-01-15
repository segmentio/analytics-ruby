
require 'analytics/request'

module Analytics

  class Consumer

    def initialize(queue, secret, options = {})
      @current_batch = []
      @queue = queue
      @batch_size = 1
      @secret = secret
      puts "Consumer intialized"
    end

    def run
      while true do
        puts "Flushing"
        flush
      end
    end

    private

    def flush

      while @current_batch.length < @batch_size do
        @current_batch << @queue.pop()
      end

      request = Analytics::Request.new
      request.post(@secret, @current_batch)
      @current_batch = []
    end

  end
end