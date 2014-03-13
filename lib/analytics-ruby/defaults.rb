
module AnalyticsRuby
  module Defaults

    module Request
      HOST = 'api.segment.io' unless defined? AnalyticsRuby::Defaults::Request::HOST
      PORT = 443 unless defined? AnalyticsRuby::Defaults::Request::PORT
      PATH = '/v1/import' unless defined? AnalyticsRuby::Defaults::Request::PATH
      SSL = true unless defined? AnalyticsRuby::Defaults::Request::SSL
      HEADERS = { :accept => 'application/json' } unless defined? AnalyticsRuby::Defaults::Request::HEADERS
      RETRIES = 4 unless defined? AnalyticsRuby::Defaults::Request::RETRIES
      BACKOFF = 30.0 unless defined? AnalyticsRuby::Defaults::Request::BACKOFF
    end

    module Queue
      BATCH_SIZE = 100 unless defined? AnalyticsRuby::Defaults::Queue::BATCH_SIZE
      MAX_SIZE = 10000 unless defined? AnalyticsRuby::Defaults::Queue::MAX_SIZE
    end

  end
end
