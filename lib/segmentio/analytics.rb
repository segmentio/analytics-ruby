require 'segmentio/analytics/version'
require 'segmentio/analytics/defaults'
require 'segmentio/analytics/utils'
require 'segmentio/analytics/field_parser'
require 'segmentio/analytics/client'
require 'segmentio/analytics/worker'
require 'segmentio/analytics/transport'
require 'segmentio/analytics/response'
require 'segmentio/analytics/logging'

module Segmentio
  class Analytics
    # Initializes a new instance of {Segment::Analytics::Client}, to which all
    # method calls are proxied.
    #
    # @param options includes options that are passed down to
    #   {Segment::Analytics::Client#initialize}
    # @option options [Boolean] :stub (false) If true, requests don't hit the
    #   server and are stubbed to be successful.
    def initialize(options = {})
      Transport.stub = options[:stub] if options.has_key?(:stub)
      @client = Segmentio::Analytics::Client.new options
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
