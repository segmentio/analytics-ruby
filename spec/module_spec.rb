require 'analytics-ruby'
require 'spec_helper'

describe Analytics do

  describe '#not-initialized' do
    it 'should ignore calls to track if not initialized' do
      expect { Analytics.track({}) }.not_to raise_error
    end

    it 'should return false on track if not initialized' do
      Analytics.track({}).should == false
    end

    it 'should ignore calls to identify if not initialized' do
      expect { Analytics.identify({}) }.not_to raise_error
    end

    it 'should return false on identify if not initialized' do
      Analytics.identify({}).should == false
    end
  end

  describe '#init' do

    it 'should successfully init' do
      Analytics.init :secret => AnalyticsHelpers::SECRET
    end
  end

  describe '#track' do

    it 'should error without an event' do
      expect { Analytics.track :user_id => 'user' }.to raise_error(ArgumentError)
    end

    it 'should error without a user_id' do
      expect { Analytics.track :event => 'Event' }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      Analytics.track AnalyticsHelpers::Queued::TRACK
      sleep(1)
    end
  end


  describe '#identify' do
    it 'should error without a user_id' do
      expect { Analytics.identify :traits => {} }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      Analytics.identify AnalyticsHelpers::Queued::IDENTIFY
      sleep(1)
    end
  end

  describe '#alias' do
    it 'should error without from' do
      expect { Analytics.alias :to => 1234 }.to raise_error(ArgumentError)
    end

    it 'should error without to' do
      expect { Analytics.alias :from => 1234 }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      Analytics.alias AnalyticsHelpers::ALIAS
      sleep(1)
    end
  end

  describe '#flush' do

    it 'should flush without error' do
      Analytics.identify AnalyticsHelpers::Queued::IDENTIFY
      Analytics.flush
    end
  end
end
