
require 'analytics/defaults'
require 'analytics/request'

module Analytics

  class Consumer

    def initialize(queue, secret, options = {})
      @current_batch = []
      @queue = queue
      @batch_size = options[:batch_size] || Analytics::Defaults::Queue::BATCH_SIZE
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

      puts "Waiting for messages"

      # Block until we have something to send
      @current_batch << @queue.pop()

      while @current_batch.length < @batch_size && !@queue.empty? do
        @current_batch << @queue.pop()
      end

      puts "Posting #{@current_batch.length} elements."

      request = Analytics::Request.new
      request.post(@secret, @current_batch)
      @current_batch = []
    end

  end
end