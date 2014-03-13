
require 'analytics-ruby/defaults'
require 'analytics-ruby/response'
require 'net/http'
require 'net/https'
require 'json'

module AnalyticsRuby

  class Request

    # public: Creates a new request object to send analytics batch
    #
    def initialize(options = {})
      options[:host] ||= Defaults::Request::HOST
      options[:port] ||= Defaults::Request::PORT
      options[:ssl] ||= Defaults::Request::SSL
      options[:headers] ||= Defaults::Request::HEADERS
      @path = options[:path] || Defaults::Request::PATH
      @retries = options[:retries] || Defaults::Request::RETRIES
      @backoff = options[:backoff] || Defaults::Request::BACKOFF

      http = Net::HTTP.new(options[:host], options[:port])
      http.use_ssl = options[:ssl]
      http.read_timeout = 8
      http.open_timeout = 4

      @http = http
    end

    # public: Posts the secret and batch of messages to the API.
    #
    # returns - Response of the status and error if it exists
    def post(secret, batch)

      status, error = nil, nil
      remaining_retries = @retries
      backoff = @backoff
      headers = { 'Content-Type' => 'application/json', 'accept' => 'application/json' }
      begin
        payload = JSON.generate :secret => secret, :batch => batch
        res = @http.request(Net::HTTP::Post.new(@path, headers), payload)
        status = res.code.to_i
        body = JSON.parse(res.body)
        error = body["error"]

      rescue Exception => err
        puts "err: #{err}"
        status = -1
        error = "Connection error: #{err}"
        puts "retries: #{remaining_retries}"
        unless (remaining_retries -=1).zero?
          sleep(backoff)
          retry
        end
      end

      Response.new status, error
    end
  end
end
