
require 'json'
require 'faraday'
require 'faraday_middleware'
require 'typhoeus'
require 'typhoeus/adapters/faraday'

module Analytics

  class Request

    @@url = "http://localhost:7001"
    @@ssl = { verify: false }
    @@headers = { accept: "application/json" }
    @@endpoint = "/v1/import"

    def initialize(options = {})

      options[:url] ||= @@url
      options[:ssl] ||= @@ssl
      options[:headers] ||= @@headers
      @endpoint = options[:endpoint] || @@endpoint

      @conn = Faraday.new(options) do |faraday|
        faraday.request :json
        faraday.response :json, :content_type => /\bjson$/
        faraday.adapter :typhoeus
      end

      puts "Conn created"
    end

    def post(secret, batch)

      result = @conn.post do |req|
        puts "Posting! #{@endpoint}"
        puts JSON.dump(secret: secret, batch: batch)
        req.url(@endpoint)
        req.body = JSON.dump(secret: secret, batch: batch)
      end

      puts result.status
      puts result.body["error"]
    end
  end
end