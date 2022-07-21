require 'june/analytics/version'
require 'june/analytics/defaults'
require 'june/analytics/utils'
require 'june/analytics/field_parser'
require 'june/analytics/client'
require 'june/analytics/worker'
require 'june/analytics/transport'
require 'june/analytics/response'
require 'june/analytics/logging'
require 'june/analytics/test_queue'

module June
  class Analytics
    # Initializes a new instance of {June::Analytics::Client}, to which all
    # method calls are proxied.
    #
    # @param options includes options that are passed down to
    #   {June::Analytics::Client#initialize}
    # @option options [Boolean] :stub (false) If true, requests don't hit the
    #   server and are stubbed to be successful.
    def initialize(options = {})
      Transport.stub = options[:stub] if options.has_key?(:stub)
      @client = June::Analytics::Client.new options
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
