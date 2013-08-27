require 'analytics-ruby'
require 'spec_helper'


describe Analytics::Client do

  describe '#init' do

    it 'should error if no secret is supplied' do
      expect { Analytics::Client.new }.to raise_error(RuntimeError)
    end

    it 'should not error if a secret is supplied' do
      Analytics::Client.new :secret => AnalyticsHelpers::SECRET
    end

    it 'should not error if a secret is supplied as a string' do
      Analytics::Client.new 'secret' => AnalyticsHelpers::SECRET
    end
  end

  describe '#track' do

    before(:all) do
      @client = Analytics::Client.new :secret => AnalyticsHelpers::SECRET
      @client.instance_variable_get(:@thread).kill
      @queue = @client.instance_variable_get :@queue
    end

    it 'should error without an event' do
      expect { @client.track(:user_id => 'user') }.to raise_error(ArgumentError)
    end

    it 'should error without a user_id' do
      expect { @client.track(:event => 'Event') }.to raise_error(ArgumentError)
    end

    it 'should error if properties is not a hash' do
      expect {
        @client.track({
          :user_id => 'user',
          :event => 'Event',
          :properties => [1,2,3]
        })
      }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      @client.track AnalyticsHelpers::Queued::TRACK
      @queue.pop
    end

    it 'should not error when given string keys' do
      @client.track Util.stringify_keys(AnalyticsHelpers::Queued::TRACK)
      @queue.pop
    end

    it 'should convert Time properties into iso8601 format' do
      @client.track({
        :user_id => 'user',
        :event => 'Event',
        :properties => {
          :time => Time.utc(2013),
          :nottime => 'x'
        }
      })
      message = @queue.pop
      message[:properties][:time].should == '2013-01-01T00:00:00Z'
      message[:properties][:nottime].should == 'x'
    end
  end


  describe '#identify' do

    before(:all) do
      @client = Analytics::Client.new :secret => AnalyticsHelpers::SECRET
      @client.instance_variable_get(:@thread).kill
      @queue = @client.instance_variable_get :@queue
    end

    it 'should error without any user id' do
      expect { @client.identify({}) }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      @client.identify AnalyticsHelpers::Queued::IDENTIFY
      @queue.pop
    end

    it 'should not error with the required options as strings' do
      @client.identify Util.stringify_keys(AnalyticsHelpers::Queued::IDENTIFY)
      @queue.pop
    end

    it 'should convert Time traits into iso8601 format' do
      @client.identify({
        :user_id => 'user',
        :traits => {
          :time => Time.utc(2013),
          :nottime => 'x'
        }
      })
      message = @queue.pop
      message[:traits][:time].should == '2013-01-01T00:00:00Z'
      message[:traits][:nottime].should == 'x'
    end
  end

  describe '#alias' do
    before :all do
      @client = Analytics::Client.new :secret => AnalyticsHelpers::SECRET
    end

    it 'should error without from' do
      expect { @client.alias :to => 1234 }.to raise_error(ArgumentError)
    end

    it 'should error without to' do
      expect { @client.alias :from => 1234 }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      @client.alias AnalyticsHelpers::ALIAS
    end

    it 'should not error with the required options as strings' do
      @client.alias Util.stringify_keys(AnalyticsHelpers::ALIAS)
    end
  end

  describe '#flush' do
    before(:all) do
      @client = Analytics::Client.new :secret => AnalyticsHelpers::SECRET
    end

    it 'should wait for the queue to finish on a flush' do
      @client.identify AnalyticsHelpers::Queued::IDENTIFY
      @client.track AnalyticsHelpers::Queued::TRACK
      @client.flush
      @client.queued_messages.should == 0
    end
  end
end


