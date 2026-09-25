# frozen_string_literal: true

module Segment
  class Analytics
    module Defaults
      module Request
        HOST = 'api.segment.io'
        PORT = 443
        PATH = '/v1/import'
        SSL = true
        HEADERS = { 'Accept' => 'application/json',
                    'Content-Type' => 'application/json',
                    'User-Agent' => "analytics-ruby/#{Analytics::VERSION}" }
        RETRIES = 10
        MAX_TOTAL_BACKOFF_DURATION = 43_200 # 12 hours in seconds

        # Rate-limited attempts are deliberately uncounted, so this duration is the
        # only thing bounding them. It is deliberately several times
        # RATE_LIMIT_RETRY_AFTER_CAP: when the two are equal a single maximal
        # Retry-After consumes the whole budget, leaving one attempt and no retry,
        # and the cap can never be the smaller of the two so it never binds at all.
        MAX_RATE_LIMIT_DURATION = 1800 # seconds

        # A guard against an absurd header, not a second budget. Waiting less than
        # the server asked for does not make the next attempt more likely to
        # succeed, it just sends more requests at something already rate-limiting
        # us; how long we keep trying is MAX_RATE_LIMIT_DURATION's job.
        RATE_LIMIT_RETRY_AFTER_CAP = 300 # seconds
      end

      module Queue
        MAX_SIZE = 10000
      end

      module Message
        MAX_BYTES = 32768 # 32Kb
      end

      module MessageBatch
        MAX_BYTES = 512_000 # 500Kb
        MAX_SIZE = 100
      end

      module BackoffPolicy
        MIN_TIMEOUT_MS = 500
        MAX_TIMEOUT_MS = 60_000
        MULTIPLIER = 2
        RANDOMIZATION_FACTOR = 0.5
      end
    end
  end
end
