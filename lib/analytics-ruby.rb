require 'analytics-ruby/version'
require 'analytics-ruby/client'

module AnalyticsRuby
  module ClassMethods
    # By default use a single client for the module
    def init(options = {})
      @client = AnalyticsRuby::Client.new options
    end

    def track(options)
      return false unless @client
      @client.track options
    end

    def identify(options)
      return false unless @client
      @client.identify options
    end

    def alias(options)
      return false unless @client
      @client.alias options
    end

    def group(options)
      return false unless @client
      @client.group options
    end

    def page(options)
      return false unless @client
      @client.page options
    end

    def screen(options)
      return false unless @client
      @client.screen options
    end

    def flush
      return false unless @client
      @client.flush
    end

    def initialized?
      !!@client
    end
  end
  extend ClassMethods
end
