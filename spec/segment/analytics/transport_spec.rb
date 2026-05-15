# frozen_string_literal: true

require 'spec_helper'

module Segment
  class Analytics
    describe Transport do
      before do
        # Try and keep debug statements out of tests
        allow(subject.logger).to receive(:error)
        allow(subject.logger).to receive(:debug)
      end

      describe '#initialize' do
        let!(:net_http) { Net::HTTP.new(anything, anything) }

        before do
          allow(Net::HTTP).to receive(:new) { net_http }
        end

        it 'sets an initalized Net::HTTP read_timeout' do
          expect(net_http).to receive(:use_ssl=)
          described_class.new
        end

        it 'sets an initalized Net::HTTP read_timeout' do
          expect(net_http).to receive(:read_timeout=)
          described_class.new
        end

        it 'sets an initalized Net::HTTP open_timeout' do
          expect(net_http).to receive(:open_timeout=)
          described_class.new
        end

        it 'sets the http client' do
          expect(subject.instance_variable_get(:@http)).to_not be_nil
        end

        context 'no options are set' do
          it 'sets a default path' do
            path = subject.instance_variable_get(:@path)
            expect(path).to eq(described_class::PATH)
          end

          it 'sets a default retries' do
            retries = subject.instance_variable_get(:@retries)
            expect(retries).to eq(described_class::RETRIES)
          end

          it 'sets a default backoff policy' do
            backoff_policy = subject.instance_variable_get(:@backoff_policy)
            expect(backoff_policy).to be_a(Segment::Analytics::BackoffPolicy)
          end

          it 'initializes a new Net::HTTP with default host and port' do
            expect(Net::HTTP).to receive(:new).with(
              described_class::HOST,
              described_class::PORT
            )
            described_class.new
          end
        end

        context 'options are given' do
          let(:path) { 'my/cool/path' }
          let(:retries) { 1234 }
          let(:backoff_policy) { FakeBackoffPolicy.new([1, 2, 3]) }
          let(:host) { 'http://www.example.com' }
          let(:port) { 8080 }
          let(:options) do
            {
              path: path,
              retries: retries,
              backoff_policy: backoff_policy,
              host: host,
              port: port
            }
          end

          subject { described_class.new(options) }

          it 'sets passed in path' do
            expect(subject.instance_variable_get(:@path)).to eq(path)
          end

          it 'sets passed in retries' do
            expect(subject.instance_variable_get(:@retries)).to eq(retries)
          end

          it 'sets passed in backoff backoff policy' do
            expect(subject.instance_variable_get(:@backoff_policy))
              .to eq(backoff_policy)
          end

          it 'initializes a new Net::HTTP with passed in host and port' do
            expect(Net::HTTP).to receive(:new).with(host, port)
            described_class.new(options)
          end
        end
      end

      describe '#send' do
        let(:response) {
          Net::HTTPResponse.new(http_version, status_code, response_body)
        }
        let(:http_version) { 1.1 }
        let(:status_code) { 200 }
        let(:response_body) { {}.to_json }
        let(:write_key) { 'abcdefg' }
        let(:batch) { [] }

        before do
          http = subject.instance_variable_get(:@http)
          allow(http).to receive(:start)
          allow(http).to receive(:request) { response }
          allow(response).to receive(:body) { response_body }
          allow(response).to receive(:to_hash) { {} }
        end

        it 'initalizes a new Net::HTTP::Post with path and default headers' do
          path = subject.instance_variable_get(:@path)
          default_headers = {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'User-Agent' => "analytics-ruby/#{Analytics::VERSION}"
          }
          expect(Net::HTTP::Post).to receive(:new).with(
            path, default_headers
          ).and_call_original

          subject.send(write_key, batch)
        end

        it 'adds basic auth to the Net::HTTP::Post' do
          expect_any_instance_of(Net::HTTP::Post).to receive(:basic_auth)
            .with(write_key, nil)

          subject.send(write_key, batch)
        end

        context 'with a stub' do
          before do
            allow(described_class).to receive(:stub) { true }
          end

          it 'returns a 200 response' do
            expect(subject.send(write_key, batch).status).to eq(200)
          end

          it 'has a nil error' do
            expect(subject.send(write_key, batch).error).to be_nil
          end

          it 'logs a debug statement' do
            expect(subject.logger).to receive(:debug).with(/stubbed request to/)
            subject.send(write_key, batch)
          end
        end

        context 'a real request' do
          RSpec.shared_examples('retried request') do |status_code, body|
            let(:status_code) { status_code }
            let(:body) { body }
            let(:retries) { 4 }
            let(:backoff_policy) { FakeBackoffPolicy.new([1000, 1000, 1000]) }
            subject {
              described_class.new(retries: retries,
                                  backoff_policy: backoff_policy)
            }

            it 'retries the request' do
              expect(subject)
                .to receive(:sleep)
                .exactly(retries - 1).times
                .with(1)
                .and_return(nil)
              subject.send(write_key, batch)
            end
          end

          RSpec.shared_examples('non-retried request') do |status_code, body|
            let(:status_code) { status_code }
            let(:body) { body }
            let(:retries) { 4 }
            let(:backoff) { 1 }
            subject { described_class.new(retries: retries, backoff: backoff) }

            it 'does not retry the request' do
              expect(subject)
                .to receive(:sleep)
                .never
              subject.send(write_key, batch)
            end
          end

          context 'request is successful' do
            let(:status_code) { 201 }
            it 'returns a response code' do
              expect(subject.send(write_key, batch).status).to eq(status_code)
            end

            it 'returns a nil error' do
              expect(subject.send(write_key, batch).error).to be_nil
            end
          end

          context '3xx is treated as success' do
            let(:status_code) { 301 }
            it 'returns status without retrying' do
              expect(subject).not_to receive(:sleep)
              expect(subject.send(write_key, batch).status).to eq(301)
            end
          end

          context 'request results in errorful response' do
            let(:error) { 'this is an error' }
            let(:response_body) { { error: error }.to_json }

            it 'returns the parsed error' do
              expect(subject.send(write_key, batch).error).to eq(error)
            end
          end

          context 'a request returns a failure status code' do
            # Server errors must be retried
            it_behaves_like('retried request', 500, '{}')
            it_behaves_like('retried request', 503, '{}')

            # 429 is retried
            it_behaves_like('retried request', 429, '{}')
            it_behaves_like('non-retried request', 404, '{}')
            it_behaves_like('non-retried request', 400, '{}')

            # Non-retryable 5xx: 501, 505, 511
            it_behaves_like('non-retried request', 501, '{}')
            it_behaves_like('non-retried request', 505, '{}')
            it_behaves_like('non-retried request', 511, '{}')

            # Retryable 4xx: 408, 410, 460
            it_behaves_like('retried request', 408, '{}')
            it_behaves_like('retried request', 410, '{}')
            it_behaves_like('retried request', 460, '{}')
          end

          context '429 with Retry-After header' do
            let(:status_code) { 429 }
            let(:retry_after_seconds) { 2 }
            subject { described_class.new(retries: 4, backoff_policy: FakeBackoffPolicy.new([1000, 1000, 1000])) }

            before do
              allow(response).to receive(:to_hash) { { 'retry-after' => [retry_after_seconds.to_s] } }
              # Second attempt succeeds
              success_response = Net::HTTPResponse.new(1.1, 200, '{}')
              allow(success_response).to receive(:body) { '{}' }
              allow(success_response).to receive(:to_hash) { {} }
              http = subject.instance_variable_get(:@http)
              allow(http).to receive(:request).and_return(response, success_response)
            end

            it 'sleeps for the Retry-After duration' do
              expect(subject).to receive(:sleep).with(2).once
              subject.send(write_key, batch)
            end

            it 'caps Retry-After at RATE_LIMIT_RETRY_AFTER_CAP' do
              allow(response).to receive(:to_hash) { { 'retry-after' => ['9999'] } }
              expect(subject).to receive(:sleep).with(described_class::RATE_LIMIT_RETRY_AFTER_CAP).once
              subject.send(write_key, batch)
            end

            it 'returns success after retry' do
              allow(subject).to receive(:sleep)
              expect(subject.send(write_key, batch).success?).to be true
            end
          end

          context 'X-Retry-Count header' do
            let(:status_code) { 500 }
            let(:backoff_policy) { FakeBackoffPolicy.new([1, 1]) }
            subject { described_class.new(retries: 3, backoff_policy: backoff_policy) }

            it 'does not send X-Retry-Count on first attempt' do
              allow(subject).to receive(:sleep)
              first_request = nil
              http = subject.instance_variable_get(:@http)
              allow(http).to receive(:request) do |req, _|
                first_request ||= req
                response
              end
              subject.send(write_key, batch)
              expect(first_request['X-Retry-Count']).to be_nil
            end

            it 'sends X-Retry-Count incrementing on retries' do
              allow(subject).to receive(:sleep)
              requests = []
              http = subject.instance_variable_get(:@http)
              allow(http).to receive(:request) do |req, _|
                requests << req
                response
              end
              subject.send(write_key, batch)
              expect(requests[1]['X-Retry-Count']).to eq('1')
              expect(requests[2]['X-Retry-Count']).to eq('2')
            end
          end

          context 'private helpers' do
            describe '#success_status?' do
              it { expect(subject.send(:success_status?, 200)).to be true }
              it { expect(subject.send(:success_status?, 201)).to be true }
              it { expect(subject.send(:success_status?, 301)).to be true }
              it { expect(subject.send(:success_status?, 400)).to be false }
              it { expect(subject.send(:success_status?, 500)).to be false }
            end

            describe '#retryable_status?' do
              it { expect(subject.send(:retryable_status?, 500)).to be true }
              it { expect(subject.send(:retryable_status?, 503)).to be true }
              it { expect(subject.send(:retryable_status?, 429)).to be true }
              it { expect(subject.send(:retryable_status?, 408)).to be true }
              it { expect(subject.send(:retryable_status?, 410)).to be true }
              it { expect(subject.send(:retryable_status?, 460)).to be true }
              it { expect(subject.send(:retryable_status?, 400)).to be false }
              it { expect(subject.send(:retryable_status?, 404)).to be false }
              it { expect(subject.send(:retryable_status?, 501)).to be false }
              it { expect(subject.send(:retryable_status?, 505)).to be false }
              it { expect(subject.send(:retryable_status?, 511)).to be false }
            end

            describe '#parse_retry_after' do
              it { expect(subject.send(:parse_retry_after, '60')).to eq(60) }
              it { expect(subject.send(:parse_retry_after, ['60'])).to eq(60) }
              it { expect(subject.send(:parse_retry_after, '0')).to be_nil }
              it { expect(subject.send(:parse_retry_after, '-1')).to be_nil }
              it { expect(subject.send(:parse_retry_after, nil)).to be_nil }
              it { expect(subject.send(:parse_retry_after, '')).to be_nil }
              it { expect(subject.send(:parse_retry_after, 'Wed, 07 May 2026 12:00:00 GMT')).to be_nil }
            end
          end

          context 'request or parsing of response results in an exception' do
            let(:response_body) { 'Malformed JSON ---' }

            subject { described_class.new(retries: 0) }

            it 'returns a -1 for status' do
              expect(subject.send(write_key, batch).status).to eq(-1)
            end

            it 'has a connection error' do
              error = subject.send(write_key, batch).error
              expect(error).not_to be_nil
            end

            it_behaves_like('retried request', 200, 'Malformed JSON ---')
          end
        end
      end
    end
  end
end
