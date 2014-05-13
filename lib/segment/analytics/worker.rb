require 'monitor'
require 'segment/analytics/defaults'
require 'segment/analytics/utils'
require 'segment/analytics/defaults'
require 'segment/analytics/request'

module Segment
  class Analytics
    class Worker
      include Segment::Analytics::Utils
      include Segment::Analytics::Defaults

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
        @batch_size = options[:batch_size] || Queue::BATCH_SIZE
        @on_error = options[:on_error] || Proc.new { |status, error| }
        @current_batch = []
        @current_batch.extend MonitorMixin
      end

      # public: Continuously runs the loop to check for new events
      #
      def run
        loop do
          flush
        end
      end

      # public: Flush some events from our queue
      #
      def flush
        return if @queue.empty?

        @current_batch.synchronize do
          until @current_batch.length >= @batch_size || @queue.empty?
            @current_batch << @queue.pop
          end
        end

        res = Request.new.post @write_key, @current_batch
        @on_error.call res.status, res.error unless res.status == 200

        @current_batch.synchronize { @current_batch.clear }
      end

      # public: Check whether we have outstanding requests.
      #
      def is_requesting?
        @current_batch.synchronize { !@current_batch.empty? }
      end
    end
  end
end
