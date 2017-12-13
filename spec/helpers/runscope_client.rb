require 'faraday'
require 'pmap'

class RunscopeClient
  def initialize(api_token)
    headers = { 'Authorization' => "Bearer #{api_token}" }
    @conn = Faraday.new('https://api.runscope.com', headers: headers)
  end

  def requests(bucket_key)
    with_retries(3) do
      response = @conn.get("/buckets/#{bucket_key}/messages", count: 10)

      raise "Runscope error. #{response.body}" unless response.status == 200

      message_uuids = JSON.parse(response.body)['data'].map { |message|
        message.fetch('uuid')
      }

      message_uuids.pmap { |uuid|
        response = @conn.get("/buckets/#{bucket_key}/messages/#{uuid}")
        raise "Runscope error. #{response.body}" unless response.status == 200
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
end
