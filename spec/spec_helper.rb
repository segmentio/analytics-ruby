
module AnalyticsHelpers

  SECRET = 'testsecret'

  TRACK = { event:     'Ruby Library test event',
            properties: {
              type:     'Chocolate',
              is_a_lie: true,
              layers:   20,
              created:  Time.new
            }
          }

  IDENTIFY =  { traits: {
                  likes_animals: true,
                  instrument:    'Guitar',
                  age:           25
                },
                action:     'identify'
              }

  USER_ID = 'Bret'

  # Hashes sent to the client
  module Queued
    TRACK = TRACK.merge({ user_id: USER_ID })

    IDENTIFY = IDENTIFY.merge({ user_id:    USER_ID  })
  end

  # Hashes which are sent from the consumer
  module Requested
    TRACK = TRACK.merge({ userId: USER_ID,
                          action: 'track' })

    IDENTIFY = IDENTIFY.merge({ userId:    USER_ID,
                                action:    'identify' })
  end
end