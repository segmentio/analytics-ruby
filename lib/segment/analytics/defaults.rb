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
        # only thing bounding them. Five minutes keeps that in line with the
        # counted-backoff path's own worst case.
        MAX_RATE_LIMIT_DURATION = 300 # seconds

        # Kept well below MAX_RATE_LIMIT_DURATION so the budget buys several
        # attempts rather than one long sleep. At the old 300s a single sleep
        # consumed the whole budget.
        RATE_LIMIT_RETRY_AFTER_CAP = 60 # seconds
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
