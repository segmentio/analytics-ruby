
require 'forwardable'
require 'analytics-ruby/version'
require 'analytics-ruby/client'

module AnalyticsRuby
  extend SingleForwardable

  def_delegators :@client, :track, :identify

  # By default use a single client for the module
  def self.init(options = {})
    @client = AnalyticsRuby::Client.new(options)
  end

end

# Alias for AnalyticsRuby
Analytics = AnalyticsRuby
