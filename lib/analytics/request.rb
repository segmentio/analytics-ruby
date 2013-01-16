
require 'analytics/defaults'
require 'multi_json'
require 'faraday'
require 'faraday_middleware'
require 'typhoeus'
require 'typhoeus/adapters/faraday'

module Analytics

  class Request

    # Creates a new request object
    #
    def initialize(options = {})

      options[:url] ||= Analytics::Defaults::Request::BASE_URL
      options[:ssl] ||= Analytics::Defaults::Request::SSL
      options[:headers] ||= Analytics::Defaults::Request::HEADERS
      @path = options[:path] || Analytics::Defaults::Request::PATH

      @conn = Faraday.new(options) do |faraday|
        faraday.request :json
        faraday.response :json, :content_type => /\bjson$/
        faraday.adapter :typhoeus
      end
    end


    def post(secret, batch)
      @conn.post do |req|
        req.url(@path)
        req.body = MultiJson.dump(secret: secret, batch: batch)
      end
    end
  end
end