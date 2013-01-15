
require 'faraday'
require 'typhoeus'
require 'typhoeus/adapters/faraday'

module Analytics

  class Request

    @@url = "http://localhost:7001"
    @@ssl = { verify: false }
    @@headers = { accept: "application/json" }
    @@endpoint = "/v1/import"

    def initialize(options)

      options ||= {}
      options[:url] ||= @@url
      options[:ssl] ||= @@ssl
      options[:headers] ||= @@headers
      @endpoint = options[:endpoint] || @@endpoint

      @conn = Faraday.new(options) do |faraday|
        faraday.request :json
        faraday.response :json, :content_type => /\bjson$/
        faraday.adapter :typhoeus
      end
    end

    def post(secret, batch)
      @conn.post do |req|
        req.url @endpoint
        req.body JSON.dump(secret: secret, batch: batch)
      end
    end
  end
end