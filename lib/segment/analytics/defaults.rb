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
        MAX_TOTAL_BACKOFF_DURATION = 43_200  # 12 hours in seconds
        MAX_RATE_LIMIT_DURATION    = 43_200  # 12 hours in seconds
        RATE_LIMIT_RETRY_AFTER_CAP = 300     # seconds
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
