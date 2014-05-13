require 'spec_helper'

module Segment
  class Analytics
    describe Client do
      describe '#initialize' do
        it 'should error if no write_key is supplied' do
          expect { Client.new }.to raise_error(ArgumentError)
        end

        it 'should not error if a write_key is supplied' do
          Client.new :write_key => WRITE_KEY
        end

        it 'should not error if a write_key is supplied as a string' do
          Client.new 'write_key' => WRITE_KEY
        end
      end

      describe '#track' do
        before(:all) do
          @client = Client.new :write_key => WRITE_KEY
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
          @client.track Queued::TRACK
          @queue.pop
        end

        it 'should not error when given string keys' do
          @client.track Utils.stringify_keys(Queued::TRACK)
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
          @client = Client.new :write_key => WRITE_KEY
          @client.instance_variable_get(:@thread).kill
          @queue = @client.instance_variable_get :@queue
        end

        it 'should error without any user id' do
          expect { @client.identify({}) }.to raise_error(ArgumentError)
        end

        it 'should not error with the required options' do
          @client.identify Queued::IDENTIFY
          @queue.pop
        end

        it 'should not error with the required options as strings' do
          @client.identify Utils.stringify_keys(Queued::IDENTIFY)
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
          @client = Client.new :write_key => WRITE_KEY
        end

        it 'should error without from' do
          expect { @client.alias :user_id => 1234 }.to raise_error(ArgumentError)
        end

        it 'should error without to' do
          expect { @client.alias :previous_id => 1234 }.to raise_error(ArgumentError)
        end

        it 'should not error with the required options' do
          @client.alias ALIAS
        end

        it 'should not error with the required options as strings' do
          @client.alias Utils.stringify_keys(ALIAS)
        end
      end

      describe '#group' do
        before :all do
          @client = Client.new :write_key => WRITE_KEY
        end

        it 'should error without group_id' do
          expect { @client.group :user_id => 'foo' }.to raise_error(ArgumentError)
        end

        it 'should error without user_id' do
          expect { @client.group :group_id => 'foo' }.to raise_error(ArgumentError)
        end

        it 'should not error with the required options' do
          @client.group Queued::GROUP
        end

        it 'should not error with the required options as strings' do
          @client.group Utils.stringify_keys(Queued::GROUP)
        end
      end

      describe '#page' do
        before :all do
          @client = Client.new :write_key => WRITE_KEY
        end

        it 'should error without user_id' do
          expect { @client.page :name => 'foo' }.to raise_error(ArgumentError)
        end

        it 'should error without name' do
          expect { @client.page :user_id => 1 }.to raise_error(ArgumentError)
        end

        it 'should not error with the required options' do
          @client.page Queued::PAGE
        end

        it 'should not error with the required options as strings' do
          @client.page Utils.stringify_keys(Queued::PAGE)
        end
      end

      describe '#screen' do
        before :all do
          @client = Client.new :write_key => WRITE_KEY
        end

        it 'should error without user_id' do
          expect { @client.screen :name => 'foo' }.to raise_error(ArgumentError)
        end

        it 'should error without name' do
          expect { A@client.screen :user_id => 1 }.to raise_error(ArgumentError)
        end

        it 'should not error with the required options' do
          @client.screen Queued::SCREEN
        end

        it 'should not error with the required options as strings' do
          @client.screen Utils.stringify_keys(Queued::SCREEN)
        end
      end

      describe '#flush' do
        before(:all) do
          @client = Client.new :write_key => WRITE_KEY
        end

        it 'should wait for the queue to finish on a flush' do
          @client.identify Queued::IDENTIFY
          @client.track Queued::TRACK
          @client.flush
          @client.queued_messages.should == 0
        end
      end
    end
  end
end
