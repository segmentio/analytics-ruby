
module AnalyticsHelpers

  SECRET = 'testsecret'

  TRACK = { event:     'Baked a cake',
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
  SESSION_ID = '4815162342'

  # Hashes sent to the client
  module Queued
    TRACK = TRACK.merge({ user_id: USER_ID })

    IDENTIFY = IDENTIFY.merge({ user_id:    USER_ID,
                                session_id: SESSION_ID })
  end

  # Hashes which are sent from the consumer
  module Requested
    TRACK = TRACK.merge({ userId: USER_ID,
                          action: 'track' })

    IDENTIFY = IDENTIFY.merge({ userId:    USER_ID,
                                sessionId: SESSION_ID,
                                action:    'identify' })
  end
end