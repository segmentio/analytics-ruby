require 'segment/analytics/defaults'
require 'segment/analytics/utils'
require 'segment/analytics/version'
require 'segment/analytics/client'
require 'segment/analytics/consumer'
require 'segment/analytics/request'
require 'segment/analytics/response'
require 'segment/analytics/logging'

module Segment
  module Analytics
    extend self

    def setup options = {}
      @options = options
      Request.stub = @options[:stub]
    end
    alias_method :init, :setup

    def setup?
      !!@options
    end
    alias_method :"initialized?", :"setup?"

    def client
      @client ||= Segment::Analytics::Client.new @options
    end

    def method_missing message, *args, &block
      if Segment::Analytics::Client.method_defined? message
        if setup?
          client.send message, *args, &block
        else
          logger.warn "messaged ##{message} before #setup"
          nil
        end
      else
        super 
      end
    end

    include Logging
  end
end

Analytics = Segment::Analytics unless defined? Analytics

