require 'segment/analytics/version'
require 'segment/analytics/defaults'
require 'segment/analytics/utils'
require 'segment/analytics/client'
require 'segment/analytics/worker'
require 'segment/analytics/request'
require 'segment/analytics/response'
require 'segment/analytics/logging'

module Segment
  class Analytics
    # Initializes a new instance of {Segment::Analytics::Client}, to which all
    # method calls are proxied.
    #
    # @param options includes options that are passed down to
    #   {Segment::Analytics::Client#initialize}
    def initialize(options = {})
      @client = Segment::Analytics::Client.new options
    end

    def method_missing(message, *args, &block)
      if @client.respond_to? message
        @client.send message, *args, &block
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @client.respond_to?(method_name) || super
    end

    include Logging
  end
end
