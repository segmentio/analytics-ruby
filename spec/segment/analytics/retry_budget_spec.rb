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

        it 'clamps the delay to the Retry-After cap' do
          expect(budget(10).next_rate_limit_delay(600, 429)).to eq(60)
        end
      end

      describe '#next_backoff_delay' do
        it 'grants exactly as many retries as configured' do
          # The count used to be decremented before the exhaustion check, so a
          # configured N yielded N-1. go, python and java all grant N.
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
