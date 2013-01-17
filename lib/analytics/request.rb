
require 'analytics/defaults'
require 'analytics/response'
require 'multi_json'
require 'faraday'
require 'faraday_middleware'
require 'typhoeus'
require 'typhoeus/adapters/faraday'

module Analytics

  class Request

    # public: Creates a new request object to send analytics batch
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

    # public: Posts the secret and batch of messages to the API.
    #
    # returns - Response of the status and error if it exists
    def post(secret, batch)

      status, error = nil, nil

      begin
        res = @conn.post do |req|
          req.url(@path)
          req.body = MultiJson.dump(secret: secret, batch: batch)
        end
        status = res.status
        error  = res.body["error"]

      rescue Exception => err
        status = -1
        error = "Connection error: #{err}"
      end

      Analytics::Response.new(status, error)
    end
  end
end