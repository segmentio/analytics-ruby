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

  describe '#flush' do
    before(:all) do
      @client = Analytics::Client.new secret: AnalyticsHelpers::SECRET
    end

    it 'should wait for the queue to finish on a flush' do
      @client.identify AnalyticsHelpers::Queued::IDENTIFY
      @client.track AnalyticsHelpers::Queued::TRACK
      @client.flush
      @client.queued_messages.should == 0
    end
  end
end


