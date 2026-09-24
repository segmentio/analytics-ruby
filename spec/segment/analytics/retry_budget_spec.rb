# frozen_string_literal: true

require 'spec_helper'

module Segment
  class Analytics
    describe RetryBudget do
      let(:logger) { Logger.new(File::NULL) }

      def budget(retries, intervals = nil)
        described_class.new(
          :retries => retries,
          :backoff_policy => FakeBackoffPolicy.new(intervals || Array.new(retries, 1000)),
          :max_total_backoff_duration => Defaults::Request::MAX_TOTAL_BACKOFF_DURATION,
          :max_rate_limit_duration => Defaults::Request::MAX_RATE_LIMIT_DURATION,
          :rate_limit_retry_after_cap => Defaults::Request::RATE_LIMIT_RETRY_AFTER_CAP,
          :logger => logger
        )
      end

      describe '#next_rate_limit_delay' do
        it 'clamps the delay to what is left of the budget' do
          # The elapsed check runs before the wait, so without clamping a check
          # passing just inside the budget sleeps a full Retry-After on top — at a
          # 5 minute budget that doubles the bound rather than rounding it.
          subject = budget(10)
          subject.instance_variable_set(
            :@rate_limit_start_time,
            Process.clock_gettime(Process::CLOCK_MONOTONIC) - 299
          )

          delay = subject.next_rate_limit_delay(60, 429)

          expect(delay).to be <= 2
        end

        it 'never returns a negative delay when the budget has just run out' do
          subject = budget(10)
          subject.instance_variable_set(
            :@rate_limit_start_time,
            Process.clock_gettime(Process::CLOCK_MONOTONIC) -
              Defaults::Request::MAX_RATE_LIMIT_DURATION
          )

          expect(subject.next_rate_limit_delay(60, 429)).to be_nil
        end

        it 'cannot return a negative delay if the budget expires mid-calculation' do
          # Kernel#sleep raises ArgumentError on a negative interval rather than
          # returning, so reading the clock once for the budget test and again for
          # the delay lets the budget expire between them and crashes the worker.
          # The stubbed clock advances past the budget on the later reading, which
          # only a single-reading implementation is immune to.
          budget_s = Defaults::Request::MAX_RATE_LIMIT_DURATION
          start = 1000.0
          subject = budget(10)
          allow(subject).to receive(:monotonic_now).and_return(
            start, # episode start
            start + budget_s - 0.001, # a budget test, just inside
            start + budget_s + 0.001  # any later reading, just outside
          )

          delay = subject.next_rate_limit_delay(60, 429)

          expect(delay.nil? || delay >= 0).to be(true),
                                              "returned #{delay.inspect}, which sleep would reject"
        end

        it 'returns a small positive delay at the very edge of the budget' do
          subject = budget(10)
          subject.instance_variable_set(
            :@rate_limit_start_time,
            Process.clock_gettime(Process::CLOCK_MONOTONIC) -
              (Defaults::Request::MAX_RATE_LIMIT_DURATION - 0.5)
          )

          delay = subject.next_rate_limit_delay(60, 429)

          expect(delay).to be > 0
          expect(delay).to be <= 0.5
        end

        it 'clamps the delay to the Retry-After cap' do
          expect(budget(10).next_rate_limit_delay(600, 429)).to eq(60)
        end
      end

      describe '#next_backoff_delay' do
        it 'grants exactly as many retries as configured' do
          # N means N. Decrementing before the exhaustion check spends one retry on
          # the check itself and silently yields N-1.
          subject = budget(3)

          expect(subject.next_backoff_delay).to eq(1.0)
          expect(subject.next_backoff_delay).to eq(1.0)
          expect(subject.next_backoff_delay).to eq(1.0)
          expect(subject.next_backoff_delay).to be_nil
        end

        it 'grants one retry for retries: 1' do
          subject = budget(1)

          expect(subject.next_backoff_delay).to eq(1.0)
          expect(subject.next_backoff_delay).to be_nil
        end

        it 'grants no retries for retries: 0' do
          # retries: 0 and retries: 1 were previously indistinguishable.
          subject = budget(0, [1000])

          expect(subject.next_backoff_delay).to be_nil
        end
      end
    end
  end
end
