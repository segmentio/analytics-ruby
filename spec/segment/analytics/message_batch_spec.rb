require 'spec_helper'

module Segment
  class Analytics
    describe MessageBatch do
      describe '#<<' do
        subject { described_class.new(100) }

        it 'appends messages' do
          subject << Message.new('a' => 'b')
          expect(subject.length).to eq(1)
        end

        it 'rejects messages that exceed the maximum allowed size' do
          max_bytes = Segment::Analytics::Defaults::Message::MAX_BYTES
          hash = { 'a' => 'b' * max_bytes }
          message = Message.new(hash)

          subject << message
          expect(subject.length).to eq(0)
        end
      end
    end
  end
end
