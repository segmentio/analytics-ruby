require 'segment/analytics/defaults'
require 'segment/analytics/message'
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
      # queue   - Queue synchronized between client and worker
      # write_key  - String of the project's Write key
      # options - Hash of worker options
      #           batch_size - Fixnum of how many items to send in a batch
      #           on_error   - Proc of what to do on an error
      #
      def initialize(queue, write_key, options = {})
        symbolize_keys! options
        @queue = queue
        @write_key = write_key
        @on_error = options[:on_error] || proc { |status, error| }
        batch_size = options[:batch_size] || Defaults::MessageBatch::MAX_SIZE
        @batch = MessageBatch.new(batch_size)
        @lock = Mutex.new
        @request = Request.new
      end

      # public: Continuously runs the loop to check for new events
      #
      def run
        until Thread.current[:should_exit]
          return if @queue.empty?

          @lock.synchronize do
            until @batch.full? || @queue.empty?
              @batch << Message.new(@queue.pop)
            end
          end

          logger.debug("Sending request for #{@batch.length} items")
          res = @request.post(@write_key, @batch)
          @on_error.call(res.status, res.error) unless res.status == 200

          @lock.synchronize { @batch.clear }
        end
      end

      # public: Check whether we have outstanding requests.
      #
      def is_requesting?
        @lock.synchronize { !@batch.empty? }
      end
    end
  end
end
