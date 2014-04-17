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

  describe '#group' do
    it 'should error without group_id' do
      expect { AnalyticsRuby.group :user_id => 'foo' }.to raise_error(ArgumentError)
    end

    it 'should error without user_id' do
      expect { AnalyticsRuby.group :group_id => 'foo' }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      AnalyticsRuby.group AnalyticsRubyHelpers::Queued::GROUP
      sleep(1)
    end
  end

  describe '#page' do
    it 'should error without user_id' do
      expect { AnalyticsRuby.page :name => 'foo' }.to raise_error(ArgumentError)
    end

    it 'should error without name' do
      expect { AnalyticsRuby.page :user_id => 1 }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      AnalyticsRuby.page AnalyticsRubyHelpers::Queued::PAGE
      sleep(1)
    end
  end

  describe '#screen' do
    it 'should error without user_id' do
      expect { AnalyticsRuby.screen :name => 'foo' }.to raise_error(ArgumentError)
    end

    it 'should error without name' do
      expect { AnalyticsRuby.screen :user_id => 1 }.to raise_error(ArgumentError)
    end

    it 'should not error with the required options' do
      AnalyticsRuby.screen AnalyticsRubyHelpers::Queued::SCREEN
      sleep(1)
    end
  end

  describe '#flush' do

    it 'should flush without error' do
      AnalyticsRuby.identify AnalyticsRubyHelpers::Queued::IDENTIFY
      AnalyticsRuby.flush
    end
  end

  describe "#initialized?" do

    context "when initialized" do
      it "should return true" do
        AnalyticsRuby.init :secret => AnalyticsRubyHelpers::SECRET
        expect(AnalyticsRuby.initialized?).to be_true
      end
    end
  end
end
