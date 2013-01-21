
module AnalyticsRuby
  module Defaults

    module Request
      BASE_URL = 'https://api.segment.io' unless defined? AnalyticsRuby::Defaults::Request::BASE_URL
      PATH = '/v1/import' unless defined? AnalyticsRuby::Defaults::Request::PATH
      SSL = { verify: false } unless defined? AnalyticsRuby::Defaults::Request::SSL
      HEADERS = { accept: 'application/json' } unless defined? AnalyticsRuby::Defaults::Request::HEADERS
    end

    module Queue
      BATCH_SIZE = 100 unless defined? AnalyticsRuby::Defaults::Queue::BATCH_SIZE
      MAX_SIZE = 10000 unless defined? AnalyticsRuby::Defaults::Queue::MAX_SIZE
    end

  end
end
