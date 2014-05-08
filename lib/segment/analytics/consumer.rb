require 'segment/analytics/defaults'
require 'segment/analytics/utils'
require 'segment/analytics/defaults'
require 'segment/analytics/request'

module Segment
  module Analytics
    class Consumer
      include Segment::Analytics::Utils
      include Segment::Analytics::Defaults

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
        symbolize_keys! options
        @queue = queue
        @secret = secret
        @batch_size = options[:batch_size] || Queue::BATCH_SIZE
        @on_error = options[:on_error] || Proc.new { |status, error| }
        @current_batch = []
        @mutex = Mutex.new
      end

      # public: Continuously runs the loop to check for new events
      #
      def run
        until Thread.current[:should_exit]
          flush
        end
      end

      # public: Flush some events from our queue
      #
      def flush
        # Block until we have something to send
        item = @queue.pop
        return if item.nil?

        # Synchronize on additions to the current batch
        @mutex.synchronize {
          @current_batch << item
          until @current_batch.length >= @batch_size || @queue.empty?
            @current_batch << @queue.pop
          end
        }

        req = Request.new
        res = req.post @secret, @current_batch
        @on_error.call res.status, res.error unless res.status == 200
        @mutex.synchronize {
          @current_batch = []
        }
      end

      # public: Check whether we have outstanding requests.
      #
      def is_requesting?
        requesting = nil
        @mutex.synchronize {
          requesting = !@current_batch.empty?
        }
        requesting
      end
    end
  end
end
