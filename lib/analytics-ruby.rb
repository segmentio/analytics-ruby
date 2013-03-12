require 'analytics-ruby/version'
require 'analytics-ruby/client'

module AnalyticsRuby

  # By default use a single client for the module
  def self.init(options = {})
    @client = AnalyticsRuby::Client.new(options)
  end

  def self.track options
    return false unless @client
    @client.track(options)
  end

  def self.identify options
    return false unless @client
    @client.identify(options)
  end


end

# Alias for AnalyticsRuby
Analytics = AnalyticsRuby
