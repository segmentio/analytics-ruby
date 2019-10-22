require 'spec_helper'

module Segment
  class Analytics
    describe MessageBatch do
      subject { described_class.new(100) }

      describe '#<<' do
        it 'appends messages' do
          subject << { 'a' => 'b' }
          expect(subject.length).to eq(1)
        end

        it 'rejects messages that exceed the maximum allowed size' do
          max_bytes = Defaults::Message::MAX_BYTES
          message = { 'a' => 'b' * max_bytes }

          subject << message
          expect(subject.length).to eq(0)
        end
      end

      describe '#full?' do
        it 'returns true once item count is exceeded' do
          99.times { subject << { a: 'b' } }
          expect(subject.full?).to be(false)

          subject << { a: 'b' }
          expect(subject.full?).to be(true)
        end

        it 'returns true once max size is almost exceeded' do
          message = { a: 'b' * (Defaults::Message::MAX_BYTES - 10) }

          message_size = message.to_json.bytesize

          # Each message is under the individual limit
          expect(message_size).to be < Defaults::Message::MAX_BYTES

          # Size of the batch is over the limit
          expect(50 * message_size).to be > Defaults::MessageBatch::MAX_BYTES

          expect(subject.full?).to be(false)
          50.times { subject << message }
          expect(subject.full?).to be(true)
        end
      end
    end
  end
end
