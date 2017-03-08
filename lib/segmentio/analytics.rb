require 'segmentio/analytics/defaults'
require 'segmentio/analytics/utils'
require 'segmentio/analytics/version'
require 'segmentio/analytics/client'
require 'segmentio/analytics/worker'
require 'segmentio/analytics/request'
require 'segmentio/analytics/response'
require 'segmentio/analytics/logging'

module Segmentio
  class Analytics
    def initialize options = {}
      Request.stub = options[:stub] if options.has_key?(:stub)
      @client = Segmentio::Analytics::Client.new options
    end

    def method_missing message, *args, &block
      if @client.respond_to? message
        @client.send message, *args, &block
      else
        super
      end
    end

    def respond_to? method_name, include_private = false
      @client.respond_to?(method_name) || super
    end

    include Logging
  end
end
