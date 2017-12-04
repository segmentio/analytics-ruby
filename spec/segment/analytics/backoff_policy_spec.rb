require 'spec_helper'

module Segment
  class Analytics
    describe BackoffPolicy do
      describe '#initialize' do
        context 'no options are given' do
          it 'sets default min_timeout_ms' do
            actual = subject.instance_variable_get(:@min_timeout_ms)
            expect(actual).to eq(described_class::MIN_TIMEOUT_MS)
          end

          it 'sets default max_timeout_ms' do
            actual = subject.instance_variable_get(:@max_timeout_ms)
            expect(actual).to eq(described_class::MAX_TIMEOUT_MS)
          end

          it 'sets default multiplier' do
            actual = subject.instance_variable_get(:@multiplier)
            expect(actual).to eq(described_class::MULTIPLIER)
          end

          it 'sets default randomization factor' do
            actual = subject.instance_variable_get(:@randomization_factor)
            expect(actual).to eq(described_class::RANDOMIZATION_FACTOR)
          end
        end

        context 'options are given' do
          let(:min_timeout_ms) { 1234 }
          let(:max_timeout_ms) { 5678 }
          let(:multiplier) { 24 }
          let(:randomization_factor) { 0.4 }

          let(:options) do
            {
              min_timeout_ms: min_timeout_ms,
              max_timeout_ms: max_timeout_ms,
              multiplier: multiplier,
              randomization_factor: randomization_factor
            }
          end

          subject { described_class.new(options) }

          it 'sets passed in min_timeout_ms' do
            actual = subject.instance_variable_get(:@min_timeout_ms)
            expect(actual).to eq(min_timeout_ms)
          end

          it 'sets passed in max_timeout_ms' do
            actual = subject.instance_variable_get(:@max_timeout_ms)
            expect(actual).to eq(max_timeout_ms)
          end

          it 'sets passed in multiplier' do
            actual = subject.instance_variable_get(:@multiplier)
            expect(actual).to eq(multiplier)
          end

          it 'sets passed in randomization_factor' do
            actual = subject.instance_variable_get(:@randomization_factor)
            expect(actual).to eq(randomization_factor)
          end
        end
      end

      describe '#next_interval' do
        subject {
          described_class.new(
            min_timeout_ms: 1000,
            max_timeout_ms: 10000,
            multiplier: 2,
            randomization_factor: 0.5
          )
        }

        it 'returns exponentially increasing durations' do
          expect(subject.next_interval).to be_within(500).of(1000)
          expect(subject.next_interval).to be_within(1000).of(2000)
          expect(subject.next_interval).to be_within(2000).of(4000)
          expect(subject.next_interval).to be_within(4000).of(8000)
        end

        it 'caps maximum duration at max_timeout_secs' do
          10.times { subject.next_interval }
          expect(subject.next_interval).to eq(10000)
        end
      end
    end
  end
end
