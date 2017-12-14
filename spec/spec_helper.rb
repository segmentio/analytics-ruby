# https://github.com/codecov/codecov-ruby#usage
require 'simplecov'
SimpleCov.start
require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require 'segment/analytics'
require 'active_support/time'
require './spec/helpers/runscope_client'

# Setting timezone for ActiveSupport::TimeWithZone to UTC
Time.zone = 'UTC'

module Segment
  class Analytics
    WRITE_KEY = 'testsecret'

    TRACK = {
      :event => 'Ruby Library test event',
      :properties => {
        :type => 'Chocolate',
        :is_a_lie => true,
        :layers => 20,
        :created =>  Time.new
      }
    }

    IDENTIFY = {
      :traits => {
        :likes_animals => true,
        :instrument => 'Guitar',
        :age => 25
      }
    }

    ALIAS = {
      :previous_id => 1234,
      :user_id => 'abcd'
    }

    GROUP = {}

    PAGE = {
      :name => 'home'
    }

    SCREEN = {
      :name => 'main'
    }

    USER_ID = 1234
    GROUP_ID = 1234

    # Hashes sent to the client, snake_case
    module Queued
      TRACK = TRACK.merge :user_id => USER_ID
      IDENTIFY = IDENTIFY.merge :user_id => USER_ID
      GROUP = GROUP.merge :group_id => GROUP_ID, :user_id => USER_ID
      PAGE = PAGE.merge :user_id => USER_ID
      SCREEN = SCREEN.merge :user_id => USER_ID
    end

    # Hashes which are sent from the worker, camel_cased
    module Requested
      TRACK = TRACK.merge({
        :userId => USER_ID,
        :type => 'track'
      })

      IDENTIFY = IDENTIFY.merge({
        :userId => USER_ID,
        :type => 'identify'
      })

      GROUP = GROUP.merge({
        :groupId => GROUP_ID,
        :userId => USER_ID,
        :type => 'group'
      })

      PAGE = PAGE.merge :userId => USER_ID
      SCREEN = SCREEN.merge :userId => USER_ID
    end
  end
end

# A worker that doesn't consume jobs
class NoopWorker
  def run
    # Does nothing
  end
end

# A backoff policy that returns a fixed list of values
class FakeBackoffPolicy
  def initialize(interval_values)
    @interval_values = interval_values
  end

  def next_interval
    raise 'FakeBackoffPolicy has no values left' if @interval_values.empty?
    @interval_values.shift
  end
end

# usage:
# it "should return a result of 5" do
#   eventually(options: {timeout: 1}) { long_running_thing.result.should eq(5) }
# end

module AsyncHelper
  def eventually(options = {})
    timeout = options[:timeout] || 2
    interval = options[:interval] || 0.1
    time_limit = Time.now + timeout
    loop do
      begin
        yield
        return
      rescue RSpec::Expectations::ExpectationNotMetError => error
        raise error if Time.now >= time_limit
        sleep interval
      end
    end
  end
end

include AsyncHelper
