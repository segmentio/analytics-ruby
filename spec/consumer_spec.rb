require 'analytics-ruby'
require 'thread'
require 'spec_helper'

describe Analytics::Consumer do

  describe '#flush' do

    it 'should not error if the endpoint is unreachable' do

      Faraday::Connection.any_instance.stub(:post).and_raise(Exception)

      queue = Queue.new
      queue << {}
      consumer = Analytics::Consumer.new(queue, 'secret')
      consumer.flush

      queue.should be_empty

      Faraday::Connection.any_instance.unstub(:post)
    end

    it 'should execute the error handler if the request is invalid' do

      Analytics::Request.any_instance
                        .stub(:post)
                        .and_return(Analytics::Response.new(400, "Some error"))

      on_error = Proc.new do |status, error|
        puts "#{status}, #{error}"
      end

      on_error.should_receive(:call).once

      queue = Queue.new
      queue << {}
      consumer = Analytics::Consumer.new(queue, 'secret', { on_error: on_error })
      consumer.flush

      Analytics::Request::any_instance.unstub(:post)

      queue.should be_empty
    end

    it 'should not call on_error if the request is good' do

      on_error = Proc.new do |status, error|
        puts "#{status}, #{error}"
      end

      on_error.should_receive(:call).at_most(0).times

      queue = Queue.new
      queue << AnalyticsHelpers::Requested::TRACK
      consumer = Analytics::Consumer.new(queue, 'testsecret', { on_error: on_error })
      consumer.flush

      queue.should be_empty
    end
  end
end