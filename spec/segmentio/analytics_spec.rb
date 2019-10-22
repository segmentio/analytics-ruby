require 'spec_helper'

module Segmentio
  class Analytics
    describe Analytics do
      let(:analytics) { Segmentio::Analytics.new :write_key => WRITE_KEY, :stub => true }

      describe '#track' do
        it 'errors without an event' do
          expect { analytics.track(:user_id => 'user') }.to raise_error(ArgumentError)
        end

        it 'errors without user_id or anonymous_id' do
          expect { analytics.track :event => 'event' }.to raise_error(ArgumentError)
          expect { analytics.track :event => 'event', user_id: '1234' }.to_not raise_error(ArgumentError)
          expect { analytics.track :event => 'event', anonymous_id: '2345' }.to_not raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect do
            analytics.track Queued::TRACK
            analytics.flush
          end.to_not raise_error
        end
      end

      describe '#identify' do
        it 'errors without user_id or anonymous_id' do
          expect { analytics.identify :traits => {} }.to raise_error(ArgumentError)
          expect { analytics.identify :traits => {}, user_id: '1234' }.to_not raise_error(ArgumentError)
          expect { analytics.identify :traits => {}, anonymous_id: '2345' }.to_not raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          analytics.identify Queued::IDENTIFY
          analytics.flush
        end
      end

      describe '#alias' do
        it 'errors without previous_id' do
          expect { analytics.alias :user_id => 1234 }.to raise_error(ArgumentError)
        end

        it 'errors without user_id or anonymous_id' do
          expect { analytics.alias :previous_id => 'foo' }.to raise_error(ArgumentError)
          expect { analytics.alias :previous_id => 'foo', user_id: '1234' }.to_not raise_error(ArgumentError)
          expect { analytics.alias :previous_id => 'foo', anonymous_id: '2345' }.to_not raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect do
            analytics.alias ALIAS
            analytics.flush
          end.to_not raise_error
        end
      end

      describe '#group' do
        it 'errors without group_id' do
          expect { analytics.group :user_id => 'foo' }.to raise_error(ArgumentError)
        end

        it 'errors without user_id or anonymous_id' do
          expect { analytics.group :group_id => 'foo' }.to raise_error(ArgumentError)
          expect { analytics.group :group_id => 'foo', user_id: '1234' }.to_not raise_error(ArgumentError)
          expect { analytics.group :group_id => 'foo', anonymous_id: '2345' }.to_not raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect do
            analytics.group Queued::GROUP
            analytics.flush
          end.to_not raise_error
        end
      end

      describe '#page' do
        it 'errors without user_id or anonymous_id' do
          expect { analytics.page :name => 'foo' }.to raise_error(ArgumentError)
          expect { analytics.page :name => 'foo', user_id: '1234' }.to_not raise_error(ArgumentError)
          expect { analytics.page :name => 'foo', anonymous_id: '2345' }.to_not raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect do
            analytics.page Queued::PAGE
            analytics.flush
          end.to_not raise_error
        end
      end

      describe '#screen' do
        it 'errors without user_id or anonymous_id' do
          expect { analytics.screen :name => 'foo' }.to raise_error(ArgumentError)
          expect { analytics.screen :name => 'foo', user_id: '1234' }.to_not raise_error(ArgumentError)
          expect { analytics.screen :name => 'foo', anonymous_id: '2345' }.to_not raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect do
            analytics.screen Queued::SCREEN
            analytics.flush
          end.to_not raise_error
        end
      end

      describe '#flush' do
        it 'flushes without error' do
          expect do
            analytics.identify Queued::IDENTIFY
            analytics.flush
          end.to_not raise_error
        end
      end

      describe '#respond_to?' do
        it 'responds to all public instance methods of Segmentio::Analytics::Client' do
          expect(analytics).to respond_to(*Segmentio::Analytics::Client.public_instance_methods(false))
        end
      end

      describe '#method' do
        Segmentio::Analytics::Client.public_instance_methods(false).each do |public_method|
          it "returns a Method object with '#{public_method}' as argument" do
            expect(analytics.method(public_method).class).to eq(Method)
          end
        end
      end
    end
  end
end
