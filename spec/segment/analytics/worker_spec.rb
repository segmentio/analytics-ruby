require 'spec_helper'

module Segment
  class Analytics
    describe Worker do
      describe '#init' do
        it 'accepts string keys' do
          queue = Queue.new
          worker = Segment::Analytics::Worker.new(queue,
                                                  'secret',
                                                  'batch_size' => 100)
          batch = worker.instance_variable_get(:@batch)
          expect(batch.instance_variable_get(:@max_message_count)).to eq(100)
        end
      end

      describe '#run' do
        before :all do
          Segment::Analytics::Defaults::Request::BACKOFF = 0.1
        end

        after :all do
          Segment::Analytics::Defaults::Request::BACKOFF = 30.0
        end

        it 'does not error if the endpoint is unreachable' do
          expect do
            Net::HTTP.any_instance.stub(:post).and_raise(Exception)

            queue = Queue.new
            queue << {}
            worker = Segment::Analytics::Worker.new(queue, 'secret')
            worker.run

            expect(queue).to be_empty

            Net::HTTP.any_instance.unstub(:post)
          end.to_not raise_error
        end

        it 'executes the error handler if the request is invalid' do
          Segment::Analytics::Request
            .any_instance
            .stub(:post)
            .and_return(Segment::Analytics::Response.new(400, 'Some error'))

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

          Segment::Analytics::Request.any_instance.unstub(:post)

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

        context 'should exit is set' do
          it 'does not return until the queue is empty' do
            allow_any_instance_of(Thread).to receive(:[]).with(:should_exit).and_return(false, true)

            queue = Queue.new
            queue << Requested::TRACK
            queue << Requested::TRACK
            queue << Requested::TRACK
            worker = Segment::Analytics::Worker.new queue, 'testsecret', :batch_size => 1
            worker.run

            expect(queue).to be_empty
          end
        end
      end

      describe '#is_requesting?' do
        it 'does not return true if there isn\'t a current batch' do
          queue = Queue.new
          worker = Segment::Analytics::Worker.new(queue, 'testsecret')

          expect(worker.is_requesting?).to eq(false)
        end

        it 'returns true if there is a current batch' do
          queue = Queue.new
          queue << Requested::TRACK
          worker = Segment::Analytics::Worker.new(queue, 'testsecret')

          worker_thread = Thread.new { worker.run }
          eventually { expect(worker.is_requesting?).to eq(true) }

          worker_thread.join
          expect(worker.is_requesting?).to eq(false)
        end
      end
    end
  end
end
