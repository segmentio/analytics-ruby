require 'spec_helper'

module Segmentio
  class Analytics
    describe Worker do
      before do
        Segmentio::Analytics::Transport.stub = true
      end

      describe '#init' do
        it 'accepts string keys' do
          queue = Queue.new
          worker = Segmentio::Analytics::Worker.new(queue,
                                                  'secret',
                                                  'batch_size' => 100)
          batch = worker.instance_variable_get(:@batch)
          expect(batch.instance_variable_get(:@max_message_count)).to eq(100)
        end
      end

      describe '#run' do
        before :all do
          Segmentio::Analytics::Defaults::Request::BACKOFF = 0.1
        end

        after :all do
          Segmentio::Analytics::Defaults::Request::BACKOFF = 30.0
        end

        it 'does not error if the request fails' do
          expect do
            Segmentio::Analytics::Transport
              .any_instance
              .stub(:send)
              .and_return(Segmentio::Analytics::Response.new(-1, 'Unknown error'))

            queue = Queue.new
            queue << {}
            worker = Segmentio::Analytics::Worker.new(queue, 'secret')
            worker.run

            expect(queue).to be_empty

            Segmentio::Analytics::Transport.any_instance.unstub(:send)
          end.to_not raise_error
        end

        it 'executes the error handler if the request is invalid' do
          Segmentio::Analytics::Transport
            .any_instance
            .stub(:send)
            .and_return(Segmentio::Analytics::Response.new(400, 'Some error'))

          status = error = nil
          on_error = proc do |yielded_status, yielded_error|
            sleep 0.2 # Make this take longer than thread spin-up (below)
            status, error = yielded_status, yielded_error
          end

          queue = Queue.new
          queue << {}
          worker = described_class.new(queue, 'secret', :on_error => on_error)

          # This is to ensure that Client#flush doesn't finish before calling
          # the error handler.
          Thread.new { worker.run }
          sleep 0.1 # First give thread time to spin-up.
          sleep 0.01 while worker.is_requesting?

          Segmentio::Analytics::Transport.any_instance.unstub(:send)

          expect(queue).to be_empty
          expect(status).to eq(400)
          expect(error).to eq('Some error')
        end

        it 'does not call on_error if the request is good' do
          on_error = proc do |status, error|
            puts "#{status}, #{error}"
          end

          expect(on_error).to_not receive(:call)

          queue = Queue.new
          queue << Requested::TRACK
          worker = described_class.new(queue,
                                       'testsecret',
                                       :on_error => on_error)
          worker.run

          expect(queue).to be_empty
        end

        it 'calls on_error for bad json' do
          bad_obj = Object.new
          def bad_obj.to_json(*_args)
            raise "can't serialize to json"
          end

          on_error = proc {}
          expect(on_error).to receive(:call).once.with(-1, /serialize to json/)

          good_message = Requested::TRACK
          bad_message = Requested::TRACK.merge({ 'bad_obj' => bad_obj })

          queue = Queue.new
          queue << good_message
          queue << bad_message

          worker = described_class.new(queue,
                                       'testsecret',
                                       :on_error => on_error)
          worker.run
          expect(queue).to be_empty
        end
      end

      describe '#is_requesting?' do
        it 'does not return true if there isn\'t a current batch' do
          queue = Queue.new
          worker = Segmentio::Analytics::Worker.new(queue, 'testsecret')

          expect(worker.is_requesting?).to eq(false)
        end

        it 'returns true if there is a current batch' do
          Segmentio::Analytics::Transport
            .any_instance
            .stub(:send) {
              sleep(0.2)
              Segmentio::Analytics::Response.new(200, 'Success')
            }

          queue = Queue.new
          queue << Requested::TRACK
          worker = Segmentio::Analytics::Worker.new(queue, 'testsecret')

          worker_thread = Thread.new { worker.run }
          eventually { expect(worker.is_requesting?).to eq(true) }

          worker_thread.join
          expect(worker.is_requesting?).to eq(false)

          Segmentio::Analytics::Transport.any_instance.unstub(:send)
        end
      end
    end
  end
end
