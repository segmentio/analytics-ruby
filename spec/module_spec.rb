require 'analytics-ruby'
require 'spec_helper'

describe Analytics do

  describe '#init' do

    it 'should successfully init' do
      Analytics.init secret: AnalyticsHelpers::SECRET
    end
  end


  describe '#track' do

    it 'should error without an event' do
      expect { Analytics.track user_id: 'user' }.to raise_error(ArgumentError)
    end

    it 'should error without a user_id' do
      expect { Analytics.track event: 'Event' }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      Analytics.track AnalyticsHelpers::Queued::TRACK
      sleep(1)
    end
  end


  describe '#identify' do
    it 'should error without a user_id' do
      expect { Analytics.identify traits: {} }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      Analytics.identify AnalyticsHelpers::Queued::IDENTIFY
      sleep(1)
    end
  end
end
