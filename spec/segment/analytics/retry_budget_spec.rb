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
          # passing just inside the budget sleeps a full Retry-After on top and
          # overshoots it. Positioned one second from the end of whatever the budget
          # is, rather than at a hardcoded elapsed time, so changing the default
          # cannot quietly move this away from the edge it is testing.
          subject = budget(10)
          subject.instance_variable_set(
            :@rate_limit_start_time,
            Process.clock_gettime(Process::CLOCK_MONOTONIC) -
              (Defaults::Request::MAX_RATE_LIMIT_DURATION - 1)
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

        it 'reads the clock once, so the budget cannot expire mid-calculation' do
          # Kernel#sleep raises ArgumentError on a negative interval rather than
          # returning, so a second reading lets the budget expire between the test
          # and the delay and crashes the worker.
          #
          # The count is asserted directly because the returned value alone does not
          # discriminate: a second reading past the budget makes the method return
          # nil, which any "never negative" assertion accepts. Only the count
          # separates the fix from the defect it guards.
          budget_s = Defaults::Request::MAX_RATE_LIMIT_DURATION
          start = 1000.0
          subject = budget(10)
          allow(subject).to receive(:monotonic_now).and_return(
            start,                    # episode start, budget test and delay share this
            start + budget_s + 0.001  # any second reading, already past the budget
          )

          delay = subject.next_rate_limit_delay(60, 429)

          expect(subject).to have_received(:monotonic_now).once
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
          expect(budget(10).next_rate_limit_delay(600, 429))
            .to eq(Defaults::Request::RATE_LIMIT_RETRY_AFTER_CAP)
        end

        it 'honours a Retry-After that fits inside the cap and the budget' do
          # Waiting less than asked sends more requests at a server already
          # rate-limiting us, so a value under the cap is used as given.
          expect(budget(10).next_rate_limit_delay(120, 429)).to eq(120)
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
