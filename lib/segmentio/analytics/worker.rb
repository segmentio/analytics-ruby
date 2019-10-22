require 'segmentio/analytics/defaults'
require 'segmentio/analytics/message_batch'
require 'segmentio/analytics/transport'
require 'segmentio/analytics/utils'

module Segmentio
  class Analytics
    class Worker
      include Segmentio::Analytics::Utils
      include Segmentio::Analytics::Defaults
      include Segmentio::Analytics::Logging

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
        @transport = Transport.new
      end

      # public: Continuously runs the loop to check for new events
      #
      def run
        until Thread.current[:should_exit]
          return if @queue.empty?

          @lock.synchronize do
            consume_message_from_queue! until @batch.full? || @queue.empty?
          end

          res = @transport.send @write_key, @batch
          @on_error.call(res.status, res.error) unless res.status == 200

          @lock.synchronize { @batch.clear }
        end
      ensure
        @transport.shutdown
      end

      # public: Check whether we have outstanding requests.
      #
      def is_requesting?
        @lock.synchronize { !@batch.empty? }
      end

      private

      def consume_message_from_queue!
        @batch << @queue.pop
      rescue MessageBatch::JSONGenerationError => e
        @on_error.call(-1, e.to_s)
      end
    end
  end
end
