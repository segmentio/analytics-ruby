require 'spec_helper'

module Segment
  class Analytics
    describe Client do
      let(:client) do
        Client.new(:write_key => WRITE_KEY).tap { |client|
          # Ensure that worker doesn't consume items from the queue
          client.instance_variable_set(:@worker, NoopWorker.new)
        }
      end
      let(:queue) { client.instance_variable_get :@queue }

      describe '#initialize' do
        it 'errors if no write_key is supplied' do
          expect { Client.new }.to raise_error(ArgumentError)
        end

        it 'does not error if a write_key is supplied' do
          expect do
            Client.new :write_key => WRITE_KEY
          end.to_not raise_error
        end

        it 'does not error if a write_key is supplied as a string' do
          expect do
            Client.new 'write_key' => WRITE_KEY
          end.to_not raise_error
        end
      end

      describe '#track' do
        it 'errors without an event' do
          expect { client.track(:user_id => 'user') }.to raise_error(ArgumentError)
        end

        it 'errors without a user_id' do
          expect { client.track(:event => 'Event') }.to raise_error(ArgumentError)
        end

        it 'errors if properties is not a hash' do
          expect {
            client.track({
              :user_id => 'user',
              :event => 'Event',
              :properties => [1, 2, 3]
            })
          }.to raise_error(ArgumentError)
        end

        it 'uses the timestamp given' do
          time = Time.parse('1990-07-16 13:30:00.123 UTC')

          client.track({
            :event => 'testing the timestamp',
            :user_id => 'joe',
            :timestamp => time
          })

          msg = queue.pop

          expect(Time.parse(msg[:timestamp])).to eq(time)
        end

        it 'does not error with the required options' do
          expect do
            client.track Queued::TRACK
            queue.pop
          end.to_not raise_error
        end

        it 'does not error when given string keys' do
          expect do
            client.track Utils.stringify_keys(Queued::TRACK)
            queue.pop
          end.to_not raise_error
        end

        it 'converts time and date traits into iso8601 format' do
          client.track({
            :user_id => 'user',
            :event => 'Event',
            :properties => {
              :time => Time.utc(2013),
              :time_with_zone =>  Time.zone.parse('2013-01-01'),
              :date_time => DateTime.new(2013, 1, 1),
              :date => Date.new(2013, 1, 1),
              :nottime => 'x'
            }
          })
          message = queue.pop

          properties = message[:properties]
          expect(properties[:time]).to eq('2013-01-01T00:00:00.000Z')
          expect(properties[:time_with_zone]).to eq('2013-01-01T00:00:00.000Z')
          expect(properties[:date_time]).to eq('2013-01-01T00:00:00.000+00:00')
          expect(properties[:date]).to eq('2013-01-01')
          expect(properties[:nottime]).to eq('x')
        end
      end

      describe '#identify' do
        it 'errors without any user id' do
          expect { client.identify({}) }.to raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect do
            client.identify Queued::IDENTIFY
            queue.pop
          end.to_not raise_error
        end

        it 'does not error with the required options as strings' do
          expect do
            client.identify Utils.stringify_keys(Queued::IDENTIFY)
            queue.pop
          end.to_not raise_error
        end

        it 'converts time and date traits into iso8601 format' do
          client.identify({
            :user_id => 'user',
            :traits => {
              :time => Time.utc(2013),
              :time_with_zone =>  Time.zone.parse('2013-01-01'),
              :date_time => DateTime.new(2013, 1, 1),
              :date => Date.new(2013, 1, 1),
              :nottime => 'x'
            }
          })

          message = queue.pop

          traits = message[:traits]
          expect(traits[:time]).to eq('2013-01-01T00:00:00.000Z')
          expect(traits[:time_with_zone]).to eq('2013-01-01T00:00:00.000Z')
          expect(traits[:date_time]).to eq('2013-01-01T00:00:00.000+00:00')
          expect(traits[:date]).to eq('2013-01-01')
          expect(traits[:nottime]).to eq('x')
        end
      end

      describe '#alias' do
        it 'errors without from' do
          expect { client.alias :user_id => 1234 }.to raise_error(ArgumentError)
        end

        it 'errors without to' do
          expect { client.alias :previous_id => 1234 }.to raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect { client.alias ALIAS }.to_not raise_error
        end

        it 'does not error with the required options as strings' do
          expect do
            client.alias Utils.stringify_keys(ALIAS)
          end.to_not raise_error
        end
      end

      describe '#group' do
        it 'errors without group_id' do
          expect { client.group :user_id => 'foo' }.to raise_error(ArgumentError)
        end

        it 'errors without user_id' do
          expect { client.group :group_id => 'foo' }.to raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          client.group Queued::GROUP
        end

        it 'does not error with the required options as strings' do
          client.group Utils.stringify_keys(Queued::GROUP)
        end

        it 'converts time and date traits into iso8601 format' do
          client.identify({
            :user_id => 'user',
            :group_id => 'group',
            :traits => {
              :time => Time.utc(2013),
              :time_with_zone =>  Time.zone.parse('2013-01-01'),
              :date_time => DateTime.new(2013, 1, 1),
              :date => Date.new(2013, 1, 1),
              :nottime => 'x'
            }
          })

          message = queue.pop

          traits = message[:traits]
          expect(traits[:time]).to eq('2013-01-01T00:00:00.000Z')
          expect(traits[:time_with_zone]).to eq('2013-01-01T00:00:00.000Z')
          expect(traits[:date_time]).to eq('2013-01-01T00:00:00.000+00:00')
          expect(traits[:date]).to eq('2013-01-01')
          expect(traits[:nottime]).to eq('x')
        end
      end

      describe '#page' do
        it 'errors without user_id' do
          expect { client.page :name => 'foo' }.to raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect { client.page Queued::PAGE }.to_not raise_error
        end

        it 'does not error with the required options as strings' do
          expect do
            client.page Utils.stringify_keys(Queued::PAGE)
          end.to_not raise_error
        end
      end

      describe '#screen' do
        it 'errors without user_id' do
          expect { client.screen :name => 'foo' }.to raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect { client.screen Queued::SCREEN }.to_not raise_error
        end

        it 'does not error with the required options as strings' do
          expect do
            client.screen Utils.stringify_keys(Queued::SCREEN)
          end.to_not raise_error
        end
      end

      describe '#flush' do
        let(:client_with_worker) { Client.new(:write_key => WRITE_KEY) }

        it 'waits for the queue to finish on a flush' do
          client_with_worker.identify Queued::IDENTIFY
          client_with_worker.track Queued::TRACK
          client_with_worker.flush

          expect(client_with_worker.queued_messages).to eq(0)
        end

        unless defined? JRUBY_VERSION
          it 'completes when the process forks' do
            client_with_worker.identify Queued::IDENTIFY

            Process.fork do
              client_with_worker.track Queued::TRACK
              client_with_worker.flush
              expect(client_with_worker.queued_messages).to eq(0)
            end

            Process.wait
          end
        end
      end

      context 'common' do
        check_property = proc { |msg, k, v| msg[k] && msg[k] == v }

        let(:data) { { :user_id => 1, :group_id => 2, :previous_id => 3, :anonymous_id => 4, :message_id => 5, :event => 'coco barked', :name => 'coco' } }

        it 'does not convert ids given as fixnums to strings' do
          [:track, :screen, :page, :identify].each do |s|
            client.send(s, data)
            message = queue.pop(true)

            expect(check_property.call(message, :userId, 1)).to eq(true)
            expect(check_property.call(message, :anonymousId, 4)).to eq(true)
          end
        end

        it 'returns false if queue is full' do
          client.instance_variable_set(:@max_queue_size, 1)

          [:track, :screen, :page, :group, :identify, :alias].each do |s|
            expect(client.send(s, data)).to eq(true)
            expect(client.send(s, data)).to eq(false) # Queue is full
            queue.pop(true)
          end
        end

        it 'converts message id to string' do
          [:track, :screen, :page, :group, :identify, :alias].each do |s|
            client.send(s, data)
            message = queue.pop(true)

            expect(check_property.call(message, :messageId, '5')).to eq(true)
          end
        end

        context 'group' do
          it 'does not convert ids given as fixnums to strings' do
            client.group(data)
            message = queue.pop(true)

            expect(check_property.call(message, :userId, 1)).to eq(true)
            expect(check_property.call(message, :groupId, 2)).to eq(true)
          end
        end

        context 'alias' do
          it 'does not convert ids given as fixnums to strings' do
            client.alias(data)
            message = queue.pop(true)

            expect(check_property.call(message, :userId, 1)).to eq(true)
            expect(check_property.call(message, :previousId, 3)).to eq(true)
          end
        end

        it 'sends integrations' do
          [:track, :screen, :page, :group, :identify, :alias].each do |s|
            client.send s, :integrations => { :All => true, :Salesforce => false }, :user_id => 1, :group_id => 2, :previous_id => 3, :anonymous_id => 4, :event => 'coco barked', :name => 'coco'
            message = queue.pop(true)
            expect(message[:integrations][:All]).to eq(true)
            expect(message[:integrations][:Salesforce]).to eq(false)
          end
        end
      end
    end
  end
end
