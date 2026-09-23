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
          :max_total_backoff_duration => 43_200,
          :max_rate_limit_duration => 43_200,
          :rate_limit_retry_after_cap => 300,
          :logger => logger
        )
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
