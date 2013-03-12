require 'analytics-ruby'
require 'spec_helper'


describe Analytics::Client do

  describe '#init' do

    it 'should error if no secret is supplied' do
      expect { Analytics::Client.new }.to raise_error(RuntimeError)
    end

    it 'should not error if a secret is supplied' do
      Analytics::Client.new secret: AnalyticsHelpers::SECRET
    end

  end

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

  describe '#track' do

    before(:all) do
      @client = Analytics::Client.new secret: AnalyticsHelpers::SECRET
    end

    it 'should error without an event' do
      expect { @client.track(user_id: 'user') }.to raise_error(ArgumentError)
    end

    it 'should error without a user_id' do
      expect { @client.track(event: 'Event') }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      @client.track AnalyticsHelpers::Queued::TRACK
    end

  end


  describe '#identify' do

    before(:all) do
      @client = Analytics::Client.new secret: AnalyticsHelpers::SECRET
    end

    it 'should error without any user id' do
      expect { @client.identify({}) }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      @client.identify AnalyticsHelpers::Queued::IDENTIFY
    end

  end

end


