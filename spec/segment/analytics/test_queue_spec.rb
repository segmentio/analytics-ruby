require 'spec_helper'

module Segment
  class Analytics
    describe TestQueue do
      let(:test_queue) { described_class.new }

      describe '#initialize' do
        it 'starts empty' do
          expect(test_queue.messages).to eq({})
        end
      end

      describe '#<<' do
        let(:message) do
          {
            type: type,
            foo: 'bar'
          }
        end

        let(:expected_messages) do
          {
            type.to_sym => [message],
            all: [message]
          }
        end

        context 'when unsupported type' do
          let(:type) { :foo }

          it 'raises error' do
            expect { test_queue << message }.to raise_error(NoMethodError)
          end
        end

        context 'when supported type' do
          before do
            test_queue << message
          end

          context 'when type is alias' do
            let(:type) { :alias }

            it 'adds messages' do
              expect(test_queue.messages).to eq(expected_messages)
            end

            it 'adds type to all' do
              expect(test_queue.all).to eq([message])
            end

            it 'adds type to alias' do
              expect(test_queue.alias).to eq([message])
            end
          end

          context 'when type is group' do
            let(:type) { :group }

            it 'adds messages' do
              expect(test_queue.messages).to eq(expected_messages)
            end

            it 'adds type to all' do
              expect(test_queue.all).to eq([message])
            end

            it 'adds type to group' do
              expect(test_queue.group).to eq([message])
            end
          end

          context 'when type is identify' do
            let(:type) { :identify }

            it 'adds messages' do
              expect(test_queue.messages).to eq(expected_messages)
            end

            it 'adds type to all' do
              expect(test_queue.all).to eq([message])
            end

            it 'adds type to identify' do
              expect(test_queue.identify).to eq([message])
            end
          end

          context 'when type is page' do
            let(:type) { :page }

            it 'adds messages' do
              expect(test_queue.messages).to eq(expected_messages)
            end

            it 'adds type to all' do
              expect(test_queue.all).to eq([message])
            end

            it 'adds type to page' do
              expect(test_queue.page).to eq([message])
            end
          end

          context 'when type is screen' do
            let(:type) { :screen }

            it 'adds messages' do
              expect(test_queue.messages).to eq(expected_messages)
            end

            it 'adds type to all' do
              expect(test_queue.all).to eq([message])
            end

            it 'adds type to screen' do
              expect(test_queue.screen).to eq([message])
            end
          end

          context 'when type is track' do
            let(:type) { :track }

            it 'adds messages' do
              expect(test_queue.messages).to eq(expected_messages)
            end

            it 'adds type to all' do
              expect(test_queue.all).to eq([message])
            end

            it 'adds type to track' do
              expect(test_queue.track).to eq([message])
            end
          end
        end
      end

      describe '#count' do
        let(:message) do
          {
            type: 'alias',
            foo: 'bar'
          }
        end

        it 'returns 0' do
          expect(test_queue.count).to eq(0)
        end

        it 'returns 1' do
          test_queue << message
          expect(test_queue.count).to eq(1)
        end

        it 'returns 2' do
          test_queue << message
          test_queue << message
          expect(test_queue.count).to eq(2)
        end
      end

      describe '#[]' do
        let(:message1) do
          {
            type: 'alias',
            foo: 'bar'
          }
        end

        let(:message2) do
          {
            type: 'identify',
            foo: 'baz'
          }
        end

        it 'returns message1' do
          test_queue << message1
          expect(test_queue[0]).to eq(message1)
        end

        it 'returns message2' do
          test_queue << message2
          expect(test_queue[0]).to eq(message2)
        end

        it 'returns message2' do
          test_queue << message1
          test_queue << message2
          expect(test_queue[1]).to eq(message2)
        end
      end

      describe '#reset!' do
        let(:message) do
          {
            type: 'alias',
            foo: 'bar'
          }
        end

        it 'returns message' do
          test_queue << message
          expect(test_queue.count).to eq(1)
          test_queue.reset!
          expect(test_queue.messages).to eq({})
        end
      end
    end
  end
end
