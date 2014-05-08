require 'spec_helper'

module Segment
  module Analytics
    describe '#not-initialized' do
      it 'should ignore calls to track if not initialized' do
        expect { Segment::Analytics.track({}) }.not_to raise_error
      end

      it 'should return nil on track if not initialized' do
        Segment::Analytics.track({}).should be_nil
      end

      it 'should ignore calls to identify if not initialized' do
        expect { Segment::Analytics.identify({}) }.not_to raise_error
      end

      it 'should return nil on identify if not initialized' do
        Segment::Analytics.identify({}).should be_nil
      end
    end

    describe '#init' do

      it 'should successfully init' do
        Segment::Analytics.init :secret => SECRET
      end
    end

    describe '#track' do

      it 'should error without an event' do
        expect { Segment::Analytics.track :user_id => 'user' }.to raise_error(ArgumentError)
      end

      it 'should error without a user_id' do
        expect { Segment::Analytics.track :event => 'Event' }.to raise_error(ArgumentError)
      end

      it 'should not error with the required options' do
        Segment::Analytics.track Queued::TRACK
        sleep(1)
      end
    end


    describe '#identify' do
      it 'should error without a user_id' do
        expect { Segment::Analytics.identify :traits => {} }.to raise_error(ArgumentError)
      end

      it 'should not error with the required options' do
        Segment::Analytics.identify Queued::IDENTIFY
        sleep(1)
      end
    end

    describe '#alias' do
      it 'should error without from' do
        expect { Segment::Analytics.alias :to => 1234 }.to raise_error(ArgumentError)
      end

      it 'should error without to' do
        expect { Segment::Analytics.alias :from => 1234 }.to raise_error(ArgumentError)
      end

      it 'should not error with the required options' do
        Segment::Analytics.alias ALIAS
        sleep(1)
      end
    end

    describe '#group' do
      it 'should error without group_id' do
        expect { Segment::Analytics.group :user_id => 'foo' }.to raise_error(ArgumentError)
      end

      it 'should error without user_id' do
        expect { Segment::Analytics.group :group_id => 'foo' }.to raise_error(ArgumentError)
      end

      it 'should not error with the required options' do
        Segment::Analytics.group Queued::GROUP
        sleep(1)
      end
    end

    describe '#page' do
      it 'should error without user_id' do
        expect { Segment::Analytics.page :name => 'foo' }.to raise_error(ArgumentError)
      end

      it 'should error without name' do
        expect { Segment::Analytics.page :user_id => 1 }.to raise_error(ArgumentError)
      end

      it 'should not error with the required options' do
        Segment::Analytics.page Queued::PAGE
        sleep(1)
      end
    end

    describe '#screen' do
      it 'should error without user_id' do
        expect { Segment::Analytics.screen :name => 'foo' }.to raise_error(ArgumentError)
      end

      it 'should error without name' do
        expect { Segment::Analytics.screen :user_id => 1 }.to raise_error(ArgumentError)
      end

      it 'should not error with the required options' do
        Segment::Analytics.screen Queued::SCREEN
        sleep(1)
      end
    end

    describe '#flush' do
      it 'should flush without error' do
        Segment::Analytics.identify Queued::IDENTIFY
        Segment::Analytics.flush
      end
    end

    describe "#initialized?" do
      context "when initialized" do
        it "should return true" do
          Segment::Analytics.init :secret => SECRET
          expect(Segment::Analytics.initialized?).to be_true
        end
      end
    end
  end
end

