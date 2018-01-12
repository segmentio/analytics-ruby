require 'spec_helper'

module Segment
  class Analytics
    describe MessageBatch do
      subject { described_class.new(100) }

      describe '#<<' do
        it 'appends messages' do
          subject << Message.new('a' => 'b')
          expect(subject.length).to eq(1)
        end

        it 'rejects messages that exceed the maximum allowed size' do
          max_bytes = Defaults::Message::MAX_BYTES
          hash = { 'a' => 'b' * max_bytes }
          message = Message.new(hash)

          subject << message
          expect(subject.length).to eq(0)
        end
      end

      describe '#full?' do
        it 'returns true once item count is exceeded' do
          99.times { subject << Message.new(a: 'b') }
          expect(subject.full?).to be(false)

          subject << Message.new(a: 'b')
          expect(subject.full?).to be(true)
        end

        it 'returns true once max size is almost exceeded' do
          message = Message.new(a: 'b' * (Defaults::Message::MAX_BYTES - 10))

          # Each message is under the individual limit
          expect(message.json_size).to be < Defaults::Message::MAX_BYTES

          # Size of the batch is over the limit
          expect(50 * message.json_size).to be > Defaults::MessageBatch::MAX_BYTES

          expect(subject.full?).to be(false)
          50.times { subject << message }
          expect(subject.full?).to be(true)
        end
      end
    end
  end
end
