require 'spec_helper'

module Segment
  class Analytics
    describe Analytics do
      let(:analytics) { Segment::Analytics.new :write_key => WRITE_KEY, :stub => true }

      describe '#track' do
        it 'errors without an event' do
          expect { analytics.track(:user_id => 'user') }.to raise_error(ArgumentError)
        end

        it 'errors without a user_id' do
          expect { analytics.track(:event => 'Event') }.to raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect do
            analytics.track Queued::TRACK
            sleep(1)
          end.to_not raise_error
        end
      end

      describe '#identify' do
        it 'errors without a user_id' do
          expect { analytics.identify :traits => {} }.to raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          analytics.identify Queued::IDENTIFY
          sleep(1)
        end
      end

      describe '#alias' do
        it 'errors without from' do
          expect { analytics.alias :user_id => 1234 }.to raise_error(ArgumentError)
        end

        it 'errors without to' do
          expect { analytics.alias :previous_id => 1234 }.to raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect do
            analytics.alias ALIAS
            sleep(1)
          end.to_not raise_error
        end
      end

      describe '#group' do
        it 'errors without group_id' do
          expect { analytics.group :user_id => 'foo' }.to raise_error(ArgumentError)
        end

        it 'errors without user_id or anonymous_id' do
          expect { analytics.group :group_id => 'foo' }.to raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect do
            analytics.group Queued::GROUP
            sleep(1)
          end.to_not raise_error
        end
      end

      describe '#page' do
        it 'errors without user_id or anonymous_id' do
          expect { analytics.page :name => 'foo' }.to raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect do
            analytics.page Queued::PAGE
            sleep(1)
          end.to_not raise_error
        end
      end

      describe '#screen' do
        it 'errors without user_id or anonymous_id' do
          expect { analytics.screen :name => 'foo' }.to raise_error(ArgumentError)
        end

        it 'does not error with the required options' do
          expect do
            analytics.screen Queued::SCREEN
            sleep(1)
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
        it 'responds to all public instance methods of Segment::Analytics::Client' do
          expect(analytics).to respond_to(*Segment::Analytics::Client.public_instance_methods(false))
        end
      end

      describe '#method' do
        Segment::Analytics::Client.public_instance_methods(false).each do |public_method|
          it "returns a Method object with '#{public_method}' as argument" do
            expect(analytics.method(public_method).class).to eq(Method)
          end
        end
      end
    end
  end
end
