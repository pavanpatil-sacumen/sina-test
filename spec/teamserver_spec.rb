# frozen_string_literal: true

require 'spec_helper'

describe Teamserver do
  describe 'helpers' do
    let(:credential) do
      cred = Model::Credential.new
      cred.username = 'agent-00000000-1234-1234-1234-1234567890ab@contrastsecurity'
      cred.service_key = 'YK13LA49HSD1U'
      cred.api_key = 'demo'
      cred.teamserver_url = 'https://app.contrastsecurity.com'
      cred.org_uuid = '00000000-1234-1234-1234-1234567890ab'
      cred
    end

    let(:service_instance_id) { 'f78a7694-0835-11e8-ba89-0ed5f89f718b' }

    it 'can build correct Authorization value' do
      auth = Teamserver.build_authorization(credential)
      expect(auth).to eq('YWdlbnQtMDAwMDAwMDAtMTIzNC0xMjM0LTEyMzQtMTIzNDU2Nzg5MGFiQGNvbnRyYXN0c2VjdXJpdHk6WUsxM0xBNDlIU0QxVQ==')
    end

    it 'can build correct headers' do
      headers = Teamserver.build_headers(credential)
      expect(headers).to be_a(Hash)
      expect(headers.keys.length).to eq(4)
      expect(headers['API-Key']).to eq('demo')
      expect(headers['Authorization']).to eq('YWdlbnQtMDAwMDAwMDAtMTIzNC0xMjM0LTEyMzQtMTIzNDU2Nzg5MGFiQGNvbnRyYXN0c2VjdXJpdHk6WUsxM0xBNDlIU0QxVQ==')
      expect(headers['Content-Type']).to eq('application/json')
    end

    it 'can build a correct URL with / at end' do
      teamserver_url = 'https://app.contrastsecurity.com/'
      result = Teamserver.build_url(teamserver_url, "/instances/#{service_instance_id}")
      expect(result).to eq('https://app.contrastsecurity.com/Contrast/api/ng/pivotal/instances/f78a7694-0835-11e8-ba89-0ed5f89f718b')
    end

    it 'can build a correct URL without / at end' do
      teamserver_url = 'https://app.contrastsecurity.com'
      result = Teamserver.build_url(teamserver_url, "/instances/#{service_instance_id}")
      expect(result).to eq('https://app.contrastsecurity.com/Contrast/api/ng/pivotal/instances/f78a7694-0835-11e8-ba89-0ed5f89f718b')
    end
  end

  describe 'building the proxy' do
    describe 'with no proxy and blank proxy info' do
      let(:credential) do
        cred = Model::Credential.new
        cred.username = 'agent-00000000-1234-1234-1234-1234567890ab@contrastsecurity'
        cred.service_key = 'YK13LA49HSD1U'
        cred.api_key = 'demo'
        cred.teamserver_url = 'https://app.contrastsecurity.com'
        cred.org_uuid = '00000000-1234-1234-1234-1234567890ab'
        cred.proxy_host = ''
        cred.proxy_port = ''
        cred.proxy_user = ''
        cred.proxy_pass = ''
        cred
      end

      let(:options) { {} }

      it 'does not modify options' do
        actual_options = Teamserver.build_proxy credential
        expect(actual_options).not_to have_key(:http_proxyaddr)
        expect(actual_options).not_to have_key(:http_proxyport)
        expect(actual_options).not_to have_key(:http_proxyuser)
        expect(actual_options).not_to have_key(:http_proxypass)
      end
    end

    describe 'with no proxy and missing proxy info' do
      let(:credential) do
        cred = Model::Credential.new
        cred.username = 'agent-00000000-1234-1234-1234-1234567890ab@contrastsecurity'
        cred.service_key = 'YK13LA49HSD1U'
        cred.api_key = 'demo'
        cred.teamserver_url = 'https://app.contrastsecurity.com'
        cred.org_uuid = '00000000-1234-1234-1234-1234567890ab'
        cred
      end

      let(:options) { {} }

      it 'does not modify options' do
        actual_options = Teamserver.build_proxy credential
        expect(actual_options).not_to have_key(:http_proxyaddr)
        expect(actual_options).not_to have_key(:http_proxyport)
        expect(actual_options).not_to have_key(:http_proxyuser)
        expect(actual_options).not_to have_key(:http_proxypass)
      end
    end

    describe 'with no proxy and nil proxy info' do
      let(:credential) do
        cred = Model::Credential.new
        cred.username = 'agent-00000000-1234-1234-1234-1234567890ab@contrastsecurity'
        cred.service_key = 'YK13LA49HSD1U'
        cred.api_key = 'demo'
        cred.teamserver_url = 'https://app.contrastsecurity.com'
        cred.org_uuid = '00000000-1234-1234-1234-1234567890ab'
        cred.proxy_host = nil
        cred.proxy_port = nil
        cred.proxy_user = nil
        cred.proxy_pass = nil
        cred
      end

      let(:options) { {} }

      it 'does not modify options' do
        actual_options = Teamserver.build_proxy credential
        expect(actual_options).not_to have_key(:http_proxyaddr)
        expect(actual_options).not_to have_key(:http_proxyport)
        expect(actual_options).not_to have_key(:http_proxyuser)
        expect(actual_options).not_to have_key(:http_proxypass)
      end
    end

    describe 'with no authentication' do
      let(:credential) do
        cred = Model::Credential.new
        cred.username = 'agent-00000000-1234-1234-1234-1234567890ab@contrastsecurity'
        cred.service_key = 'YK13LA49HSD1U'
        cred.api_key = 'demo'
        cred.teamserver_url = 'https://app.contrastsecurity.com'
        cred.org_uuid = '00000000-1234-1234-1234-1234567890ab'
        cred.proxy_host = 'http://example.com'
        cred.proxy_port = '20202'
        cred.proxy_user = ''
        cred.proxy_pass = ''
        cred
      end

      let(:options) { {} }

      it 'does not modify options' do
        actual_options = Teamserver.build_proxy credential
        expect(actual_options[:http_proxyaddr]).to eq 'http://example.com'
        expect(actual_options[:http_proxyport]).to eq '20202'
        expect(actual_options).not_to have_key(:http_proxyuser)
        expect(actual_options).not_to have_key(:http_proxypass)
      end
    end

    describe 'with proxy info' do
      let(:credential) do
        cred = Model::Credential.new
        cred.username = 'agent-00000000-1234-1234-1234-1234567890ab@contrastsecurity'
        cred.service_key = 'YK13LA49HSD1U'
        cred.api_key = 'demo'
        cred.teamserver_url = 'https://app.contrastsecurity.com'
        cred.org_uuid = '00000000-1234-1234-1234-1234567890ab'
        cred.proxy_host = 'http://example.com'
        cred.proxy_port = '20202'
        cred.proxy_user = 'ausername'
        cred.proxy_pass = 'apassword'
        cred
      end

      let(:options) { {} }

      it 'does not modify options' do
        actual_options = Teamserver.build_proxy credential
        expect(actual_options[:http_proxyaddr]).to eq 'http://example.com'
        expect(actual_options[:http_proxyport]).to eq '20202'
        expect(actual_options[:http_proxyuser]).to eq 'ausername'
        expect(actual_options[:http_proxypass]).to eq 'apassword'
      end
    end

    describe 'methods' do
      let(:credential) do
        cred = Model::Credential.new
        cred.username = 'agent_119844af-42ff-4293-b06b-81d426e9a4a9_sacumentesting'
        cred.service_key = 'F2XI7ABRAUWHYLEQ'
        cred.api_key = 'RgkGf4ue7mP37qi6LFmZYlJ7kcl3u8MR'
        cred.teamserver_url = 'https://teamserver-staging.contsec.com'
        cred.org_uuid = '119844af-42ff-4293-b06b-81d426e9a4a9'
        cred
      end

      let(:service_instance_id){
        'f78a7694-0835-11e8-ba89-0ed5f89f718b'
      }
    end

    describe '.provision' do
      let(:credential) { double('Credential', org_uuid: 'org-123', teamserver_url: 'https://example.com') }

      it 'calls post_instance with correct path' do
        expect(Teamserver).to receive(:post_instance).with('/instances/abc123', credential)
        Teamserver.provision('abc123', credential)
      end
    end

    describe '.bind' do
      let(:credential) { double('Credential', org_uuid: 'org-123', teamserver_url: 'https://example.com') }

      it 'calls post_instance with the correct path and credential' do
        expect(Teamserver).to receive(:post_instance).with(
          '/instances/abc123/bindings/bind456',
          credential
        )

        Teamserver.bind('abc123', 'bind456', credential)
      end
    end

    describe '.unprovision' do
      let(:credential) do
        double('Credential',
          org_uuid: 'org-123',
          teamserver_url: 'https://example.com',
          username: 'user',
          password: 'pass',
          api_key: 'key')
      end

      it 'calls execute_with_retry with DELETE, correct URL, and options' do
        expected_url = 'https://example.com/Contrast/api/ng/pivotal/instances/abc123'
        expected_options = { headers: { 'Authorization' => 'Basic ...' } }

        allow(Teamserver).to receive(:build_url).with(credential.teamserver_url, '/instances/abc123').and_return(expected_url)
        allow(Teamserver).to receive(:build_options).with(credential).and_return(expected_options)

        expect(Teamserver).to receive(:execute_with_retry).with(:delete, expected_url, expected_options)

        Teamserver.unprovision('abc123', credential)
      end
    end

    describe '.post_instance' do
      let(:credential) do
        double('Credential',
          org_uuid: 'org-123',
          teamserver_url: 'https://example.com',
          username: 'user',
          password: 'pass',
          api_key: 'key')
      end

      it 'builds the URL and options, then calls execute_with_retry with correct args' do
        path = '/instances/my-instance'
        expected_url = 'https://example.com/Contrast/api/ng/pivotal/instances/my-instance'
        base_options = {
          headers: {
            'Authorization' => 'Basic something',
            'Content-Type' => 'application/json'
          },
          timeout: 10
        }
        expected_options = base_options.merge(
          body: { organizationUuid: 'org-123' }.to_json
        )

        allow(Teamserver).to receive(:build_url).with('https://example.com', path).and_return(expected_url)
        allow(Teamserver).to receive(:build_options).with(credential).and_return(base_options)

        expect(Teamserver).to receive(:execute_with_retry).with(:post, expected_url, expected_options)

        Teamserver.post_instance(path, credential)
      end
    end

    describe '.execute_with_retry' do
      let(:method) { :post }
      let(:url)    { 'https://example.com/endpoint' }
      let(:options) { { body: '{"foo":"bar"}' } }
      let(:response) { double('Response') }

      context 'when no error occurs' do
        it 'calls perform_request and handles the response' do
          expect(Teamserver).to receive(:perform_request).with(method, url, options).and_return(response)
          expect(Teamserver).to receive(:raise_if_server_error).with(response)
          expect(Teamserver).to receive(:handle_response).with(response)

          Teamserver.execute_with_retry(method, url, options)
        end
      end

      context 'when an error occurs and is retried' do
        let(:error_response) { StandardError.new('temporary error') }

        it 'retries after error and succeeds' do
          call_count = 0

          allow(Teamserver).to receive(:perform_request) do
            call_count += 1
            call_count == 1 ? raise(error_response) : response
          end

          allow(Teamserver).to receive(:raise_if_server_error).with(response)
          allow(Teamserver).to receive(:handle_response).with(response)
          expect(Teamserver).to receive(:retry_or_raise).with(error_response, 0).and_yield

          Teamserver.execute_with_retry(method, url, options)

          expect(call_count).to eq(2)
        end
      end

      context 'when an error occurs and is not retried' do
        let(:fatal_error) { RuntimeError.new('fatal') }

        it 'raises the error after retry_or_raise does not yield' do
          allow(Teamserver).to receive(:perform_request).and_raise(fatal_error)
          expect(Teamserver).to receive(:retry_or_raise).with(fatal_error, 0).and_raise(fatal_error)

          expect {
            Teamserver.execute_with_retry(method, url, options)
          }.to raise_error(RuntimeError, 'fatal')
        end
      end
    end

    describe '.retry_or_raise' do
      let(:error) { StandardError.new('Something went wrong') }

      before do
        stub_const('Teamserver::MAX_RETRIES', 3)
        allow(Teamserver).to receive(:handle_retry)
        allow(Teamserver::LOGGER).to receive(:error)
      end

      context 'when retries are less than MAX_RETRIES' do
        it 'calls handle_retry and yields' do
          expect(Teamserver).to receive(:handle_retry).with(error, 1)

          expect do |block|
            Teamserver.retry_or_raise(error, 1, &block)
          end.to yield_control
        end
      end

      context 'when retries equal MAX_RETRIES' do
        it 'logs an error and raises a StandardError' do
          expect(Teamserver).not_to receive(:handle_retry)
          expect(Teamserver::LOGGER).to receive(:error).with("Request failed after 3 attempts.")

          expect {
            Teamserver.retry_or_raise(error, 3)
          }.to raise_error(StandardError, "Teamserver request failed: Something went wrong")
        end
      end
    end

    describe '.perform_request' do
      let(:method)  { :post }
      let(:url)     { 'https://example.com/endpoint' }
      let(:options) { { body: '{"foo":"bar"}' } }
      let(:response) { double('Response') }

      it 'logs the request, sends the HTTP request, logs the response, and returns it' do
        expect(Teamserver).to receive(:log_request).with(method, url, options)
        expect(HTTParty).to receive(:send).with(method, url, options).and_return(response)
        expect(Teamserver).to receive(:log_response).with(response)

        result = Teamserver.perform_request(method, url, options)
        expect(result).to eq(response)
      end
    end

    describe '.raise_if_server_error' do
      context 'when response code is less than 500' do
        it 'does not raise an error' do
          response = double('Response', code: 200, body: 'OK')

          expect {
            Teamserver.raise_if_server_error(response)
          }.not_to raise_error
        end
      end

      context 'when response code is 500 or more' do
        it 'raises a StandardError with message' do
          response = double('Response', code: 502, body: 'Bad Gateway')

          expect {
            Teamserver.raise_if_server_error(response)
          }.to raise_error(StandardError, 'Server error: 502 - Bad Gateway')
        end
      end
    end

    describe '.handle_retry' do
      let(:error) { StandardError.new('Temporary issue') }
      let(:attempt) { 2 }
      let(:sleep_time) { Teamserver::RETRY_BACKOFF**attempt }

      before do
        allow(Teamserver::LOGGER).to receive(:warn)
        allow_any_instance_of(Object).to receive(:sleep) # Mocking sleep to avoid actual delay
      end

      it 'logs the retry attempt with correct message' do
        expect(Teamserver::LOGGER).to receive(:warn).with(
          "Retry #{attempt + 1}/#{Teamserver::MAX_RETRIES}: StandardError - Temporary issue. Sleeping #{sleep_time}s..."
        )

        Teamserver.handle_retry(error, attempt)
      end

      it 'calls sleep with the correct sleep time' do
        expect_any_instance_of(Object).to receive(:sleep).with(sleep_time)

        Teamserver.handle_retry(error, attempt)
      end
    end

    describe '.build_options' do
      let(:credential) { double('Credential') }

      let(:headers) { { 'Authorization' => 'Basic token' } }
      let(:proxy)   { { proxy: 'http://proxy.example.com' } }
      let(:default_timeout) { Teamserver::DEFAULT_TIMEOUT }

      before do
        allow(Teamserver).to receive(:build_headers).with(credential).and_return(headers)
        allow(Teamserver).to receive(:build_proxy).with(credential).and_return(proxy)
      end

      it 'returns a hash with headers, timeout, and proxy settings' do
        expected = {
          headers: headers,
          timeout: default_timeout
        }.merge(proxy)

        result = Teamserver.build_options(credential)

        expect(result).to eq(expected)
      end
    end

    describe '.handle_response' do
      context 'when response is successful' do
        it 'returns the response' do
          response = double('Response', success?: true)

          result = Teamserver.handle_response(response)

          expect(result).to eq(response)
        end
      end

      context 'when response is not successful' do
        it 'raises a StandardError with code and body' do
          response = double('Response',
            success?: false,
            code: 400,
            body: 'Bad Request'
          )

          expect {
            Teamserver.handle_response(response)
          }.to raise_error(StandardError, 'HTTP 400: Bad Request')
        end
      end
    end

    describe '.log_request' do
      let(:method) { :post }
      let(:url) { 'https://example.com/api' }
      let(:headers) { { 'Authorization' => 'Bearer token' } }
      let(:body) { '{"foo":"bar"}' }

      before do
        allow(Teamserver::LOGGER).to receive(:info)
        allow(Teamserver::LOGGER).to receive(:debug)
      end

      context 'when body is present in options' do
        let(:options) { { headers: headers, body: body } }

        it 'logs the method, url, headers, and body' do
          expect(Teamserver::LOGGER).to receive(:info).with("Teamserver POST Request to #{url}")
          expect(Teamserver::LOGGER).to receive(:debug).with("Headers: #{headers}")
          expect(Teamserver::LOGGER).to receive(:debug).with("Body: #{body}")

          Teamserver.log_request(method, url, options)
        end
      end

      context 'when body is not present in options' do
        let(:options) { { headers: headers } }

        it 'logs the method, url, and headers only' do
          expect(Teamserver::LOGGER).to receive(:info).with("Teamserver POST Request to #{url}")
          expect(Teamserver::LOGGER).to receive(:debug).with("Headers: #{headers}")
          expect(Teamserver::LOGGER).not_to receive(:debug).with(/Body/)

          Teamserver.log_request(method, url, options)
        end
      end
    end

    describe '.log_response' do
      let(:response) { double('Response', code: 200, body: '{"status":"ok"}') }

      before do
        allow(Teamserver::LOGGER).to receive(:info)
        allow(Teamserver::LOGGER).to receive(:debug)
      end

      it 'logs the HTTP status code and body' do
        expect(Teamserver::LOGGER).to receive(:info).with("Teamserver Response: HTTP 200")
        expect(Teamserver::LOGGER).to receive(:debug).with("Response body: #{response.body}")

        Teamserver.log_response(response)
      end
    end
  end
end
