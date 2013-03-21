require 'analytics-ruby/version'
require 'analytics-ruby/client'

module AnalyticsRuby
  module ClassMethods
    # By default use a single client for the module
    def init(options = {})
      @client = AnalyticsRuby::Client.new(options)
    end

    def track(options)
      return false unless @client
      @client.track(options)
    end

    def identify(options)
      return false unless @client
      @client.identify(options)
    end

    def flush
      return false unless @client
      @client.flush
    end
  end
  extend ClassMethods
end

# Alias for AnalyticsRuby
Analytics = AnalyticsRuby
