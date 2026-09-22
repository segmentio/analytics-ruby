# frozen_string_literal: true

require 'segment/analytics/defaults'

module Segment
  class Analytics
    class BackoffPolicy
      include Segment::Analytics::Defaults::BackoffPolicy

      # @param [Hash] opts
      # @option opts [Numeric] :min_timeout_ms The minimum backoff timeout
      # @option opts [Numeric] :max_timeout_ms The maximum backoff timeout
      # @option opts [Numeric] :multiplier The value to multiply the current
      #   interval with for each retry attempt
      # @option opts [Numeric] :randomization_factor The randomization factor
      #   to use to create a range around the retry interval
      def initialize(opts = {})
        @min_timeout_ms = opts[:min_timeout_ms] || MIN_TIMEOUT_MS
        @max_timeout_ms = opts[:max_timeout_ms] || MAX_TIMEOUT_MS
        @multiplier = opts[:multiplier] || MULTIPLIER
        @randomization_factor = opts[:randomization_factor] || RANDOMIZATION_FACTOR

        @attempts = 0
      end

      # @return [Numeric] the next backoff interval, in milliseconds.
      def next_interval
        interval = @min_timeout_ms * (@multiplier**@attempts)
        @attempts += 1

        # Clamp first, then jitter. Jittering before the clamp meant every attempt
        # at the ceiling returned exactly max_timeout_ms, so a fleet that backed off
        # together stayed in lockstep. Jitter only subtracts, so the ceiling holds.
        capped = [interval, @max_timeout_ms].min
        capped - (rand * capped * @randomization_factor)
      end

      def reset!
        @attempts = 0
      end
    end
  end
end
