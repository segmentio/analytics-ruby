require 'httparty'
require 'pmap'

class RunscopeClient
  include HTTParty
  base_uri 'https://api.runscope.com'

  def initialize(api_token)
    @api_token = api_token
  end

  def requests(bucket_key)
    with_retries(3) do
      response = self.class.get("/buckets/#{bucket_key}/messages",
                                query: { count: 10 },
                                headers: headers)

      raise "Runscope error. #{response.body}" unless response.code == 200

      message_uuids = JSON.parse(response.body)['data'].map { |message|
        message.fetch('uuid')
      }

      message_uuids.pmap { |uuid|
        url = "/buckets/#{bucket_key}/messages/#{uuid}"
        response = self.class.get(url, headers: headers)
        raise "Runscope error. #{response.body}" unless response.code == 200
        JSON.parse(response.body).fetch('data').fetch('request')
      }
    end
  end

  private

  def with_retries(max_retries)
    retries ||= 0
    yield
  rescue StandardError => e
    retries += 1
    retry if retries < max_retries
    raise e
  end

  def headers
    { 'Authorization' => "Bearer #{@api_token}" }
  end
end
