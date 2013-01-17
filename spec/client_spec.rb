require 'analytics'
require 'spec_helper'


describe Analytics::Client do

  describe '#track' do

    before(:all) do
      @client = Analytics::Client.new secret: AnalyticsHelpers::SECRET
    end

    it 'should error without an event' do
      expect { @client.track(user_id: 'user') }.to raise_error(ArgumentError)
    end

    it 'should error without a user or session' do
      expect { @client.track(event: 'Event') }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      @client.track(user_id: 'user',
                    event:   'Event')
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
      @client.identify(user_id:    'user',
                       properties: { dog: true })
    end

  end

end


