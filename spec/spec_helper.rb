require 'segment/analytics'

module Segment
  module Analytics
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

    IDENTIFY =  {
      :traits => {
        :likes_animals => true,
        :instrument => 'Guitar',
        :age => 25
      }
    }

    ALIAS = {
      :from => 1234,
      :to => 'abcd'
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

    # Hashes which are sent from the consumer, camel_cased
    module Requested
      TRACK = TRACK.merge({
        :userId => USER_ID,
        :action => 'track'
      })

      IDENTIFY = IDENTIFY.merge({
        :userId => USER_ID,
        :action => 'identify'
      })

      GROUP = GROUP.merge({
        :groupId => GROUP_ID,
        :userId => USER_ID,
        :action => 'group'
      })

      PAGE = PAGE.merge :userId => USER_ID
      SCREEN = SCREEN.merge :userId => USER_ID
    end
  end
end
