# frozen_string_literal: true

module Segment
  class Analytics
    # Tracks the two independent budgets one send may spend.
    #
    # A retryable status carrying Retry-After spends the rate-limit budget, which
    # is bounded by wall clock only. Anything else retryable spends the counted
    # backoff budget, bounded by both a retry count and wall clock. Keeping them
    # separate is what stops a rate-limited server from exhausting the retries
    # available to genuine failures.
    #
    # The caller performs the wait, so both methods return the delay in seconds,
    # or nil when the budget is spent and the batch should be abandoned.
    class RetryBudget
      attr_reader :retry_count

      # Keyword arguments would be cleaner but need Ruby 2.1; the gemspec still
      # declares >= 2.0, which is also what rubocop is configured to parse.
      def initialize(options = {})
        @retries_remaining = options[:retries]
        @backoff_policy = options[:backoff_policy]
        @max_total_backoff_duration = options[:max_total_backoff_duration]
        @max_rate_limit_duration = options[:max_rate_limit_duration]
        @rate_limit_retry_after_cap = options[:rate_limit_retry_after_cap]
        @logger = options[:logger]
        @retry_count = 0
        @backoff_start_time = nil
        @rate_limit_start_time = nil
      end

      def next_backoff_delay
        # Checked before the decrement: decrementing first spent one retry on the
        # exhaustion test itself, so a configured N only ever performed N-1, and
        # retries: 1 and retries: 0 were indistinguishable.
        return spent('Retries exhausted for batch') if @retries_remaining <= 0

        @retries_remaining -= 1

        @backoff_start_time ||= monotonic_now
        return spent('Max total backoff duration exceeded for batch') if elapsed?(@backoff_start_time, @max_total_backoff_duration)

        delay_ms = @backoff_policy.next_interval
        @logger.debug("Retrying request, #{@retries_remaining} retries left. Waiting #{delay_ms}ms")
        delay_ms.to_f / 1000
      end

      def next_rate_limit_delay(retry_after, status_code)
        @rate_limit_start_time ||= monotonic_now

        # One clock reading serves both the budget test and the delay below. Reading
        # it twice lets the budget expire between them, which yields a negative
        # remaining and a negative delay — and Kernel#sleep raises ArgumentError on
        # one rather than returning immediately.
        remaining = @max_rate_limit_duration - (monotonic_now - @rate_limit_start_time)
        return spent('Max rate limit duration exceeded for batch') if remaining <= 0

        # Clamped to what is left of the budget as well as to the cap: the check
        # above runs before the wait, so without this a check passing just inside
        # the budget would sleep a full Retry-After on top and overshoot it.
        delay = [retry_after, @rate_limit_retry_after_cap, remaining].min
        @logger.debug("Retry-After: #{delay}s on #{status_code}. Retrying after delay.")
        delay
      end

      def record_retry
        @retry_count += 1
      end

      private

      def elapsed?(start_time, limit)
        (monotonic_now - start_time) >= limit
      end

      # Wall-clock time can jump; these budgets must not expire or stretch with it.
      def monotonic_now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def spent(message)
        @logger.error(message)
        nil
      end
    end
  end
end
