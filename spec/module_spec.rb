require 'analytics-ruby'
require 'spec_helper'

describe AnalyticsRuby do

  describe '#not-initialized' do
    it 'should ignore calls to track if not initialized' do
      expect { AnalyticsRuby.track({}) }.not_to raise_error
    end

    it 'should return false on track if not initialized' do
      AnalyticsRuby.track({}).should == false
    end

    it 'should ignore calls to identify if not initialized' do
      expect { AnalyticsRuby.identify({}) }.not_to raise_error
    end

    it 'should return false on identify if not initialized' do
      AnalyticsRuby.identify({}).should == false
    end
  end

  describe '#init' do

    it 'should successfully init' do
      AnalyticsRuby.init :secret => AnalyticsRubyHelpers::SECRET
    end
  end

  describe '#track' do

    it 'should error without an event' do
      expect { AnalyticsRuby.track :user_id => 'user' }.to raise_error(ArgumentError)
    end

    it 'should error without a user_id' do
      expect { AnalyticsRuby.track :event => 'Event' }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      AnalyticsRuby.track AnalyticsRubyHelpers::Queued::TRACK
      sleep(1)
    end
  end


  describe '#identify' do
    it 'should error without a user_id' do
      expect { AnalyticsRuby.identify :traits => {} }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      AnalyticsRuby.identify AnalyticsRubyHelpers::Queued::IDENTIFY
      sleep(1)
    end
  end

  describe '#alias' do
    it 'should error without from' do
      expect { AnalyticsRuby.alias :to => 1234 }.to raise_error(ArgumentError)
    end

    it 'should error without to' do
      expect { AnalyticsRuby.alias :from => 1234 }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      AnalyticsRuby.alias AnalyticsRubyHelpers::ALIAS
      sleep(1)
    end
  end

  describe '#flush' do

    it 'should flush without error' do
      AnalyticsRuby.identify AnalyticsRubyHelpers::Queued::IDENTIFY
      AnalyticsRuby.flush
    end
  end
end
