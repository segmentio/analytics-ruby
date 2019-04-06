require 'segment/analytics/defaults'
require 'segment/analytics/message_batch'
require 'segment/analytics/request'
require 'segment/analytics/utils'

module Segment
  class Analytics
    class Worker
      include Segment::Analytics::Utils
      include Segment::Analytics::Defaults
      include Segment::Analytics::Logging

      # public: Creates a new worker
      #
      # The worker continuously takes messages off the queue
      # and makes requests to the segment.io api
      #
      # @param [Queue] queue Queue synchronized between client and worker
      # @param [String] write_key project's write key
      # @param [Hash] opts
      # @options opts [Proc] :on_error Proc of what to do on an error
      # @options opts [Integer] :batch_size How many items to send in a batch
      def initialize(queue, write_key, options = {})
        symbolize_keys! options
        @queue = queue
        @write_key = write_key
        @on_error = options[:on_error] || proc { |status, error| }
        batch_size = options[:batch_size] || Defaults::MessageBatch::MAX_SIZE
        @batch = MessageBatch.new(batch_size)
        @lock = Mutex.new
        @stub = options[:stub]
      end

      # public: Continuously runs the loop to check for new events
      #
      def run
        until Thread.current[:should_exit]
          return if @queue.empty?

          @lock.synchronize do
            @batch << @queue.pop until @batch.full? || @queue.empty?
          end

          response = send_batch_request(@batch)
          unless response.status == 200
            @on_error.call(response.status, response.error)
          end

          @lock.synchronize { @batch.clear }
        end
      end

      def send_batch_request(batch)
        Request.new(:stub => @stub).post(@write_key, batch)
      end

      # public: Check whether we have outstanding requests.
      #
      def is_requesting?
        @lock.synchronize { !@batch.empty? }
      end
    end
  end
end
