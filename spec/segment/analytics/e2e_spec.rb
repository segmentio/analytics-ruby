require 'spec_helper'

module Segment
  # End-to-end tests that send events to a segment source and verifies that a
  # webhook connected to the source (configured manually via the app) is able
  # to receive the data sent by this library.
  describe 'End-to-end tests', e2e: true do
    # Segment write key for
    # https://app.segment.com/segment-libraries/sources/analytics_ruby_e2e_test/overview.
    #
    # This source is configured to send events to the Runscope bucket used by
    # this test.
    WRITE_KEY = 'qhdMksLsQTi9MES3CHyzsWRRt4ub5VM6'

    # Runscope bucket key for https://www.runscope.com/stream/umkvkgv7ndby
    RUNSCOPE_BUCKET_KEY = 'umkvkgv7ndby'

    let(:client) { Segment::Analytics.new(write_key: WRITE_KEY) }
    let(:runscope_client) { RunscopeClient.new(ENV.fetch('RUNSCOPE_TOKEN')) }

    it 'tracks events' do
      id = SecureRandom.uuid
      client.track(
        user_id: 'dummy_user_id',
        event: 'E2E Test',
        properties: { id: id }
      )
      client.flush

      # Allow events to propagate to runscope
      eventually(timeout: 30) {
        expect(has_matching_request?(id)).to eq(true)
      }
    end

    def has_matching_request?(id)
      captured_requests = runscope_client.requests(RUNSCOPE_BUCKET_KEY)
      captured_requests.any? do |request|
        begin
          body = JSON.parse(request['body'])
          body['properties'] && body['properties']['id'] == id
        rescue JSON::ParserError
          false
        end
      end
    end
  end
end
