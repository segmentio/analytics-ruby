require 'spec_helper'

module Segment
  class Analytics
    describe Response do
      describe '#status' do
        it { expect(subject).to respond_to(:status) }
      end

      describe '#error' do
        it { expect(subject).to respond_to(:error) }
      end

      describe '#initialize' do
        let(:status) { 404 }
        let(:error) { 'Oh No' }

        subject { described_class.new(status, error) }

        it 'sets the instance variable status' do
          expect(subject.instance_variable_get(:@status)).to eq(status)
        end

        it 'sets the instance variable error' do
          expect(subject.instance_variable_get(:@error)).to eq(error)
        end
      end
    end
  end
end
