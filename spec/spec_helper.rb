
module AnalyticsHelpers

  SECRET = 'testsecret'

  module Raw

    TRACK = { event:      'Baked a cake',
              userId:    'Bret',
              properties: {
                type:     'Chocolate',
                is_a_lie: true,
                layers:   20,
                created:  Time.new
              },
              action:     'track'
            }

    IDENTIFY =  { userId:    'Bret',
                  sessionId: '4815162342',
                  traits:     {
                    likes_animals: true,
                    instrument:    'Guitar',
                    age:           25
                  },
                  action:     'identify'
                }
  end



end