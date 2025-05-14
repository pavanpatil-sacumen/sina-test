# frozen_string_literal: true

require 'spec_helper'

class Response
  attr_reader :code

  def initialize(code)
    @code = code
  end
end

describe 'ServiceBrokerApp' do
  let(:service_instance_id) { '00000000-1111-2222-3333-000000000000' }

  describe '/v2/catalog' do
    it 'returns catalog with correct auth given' do
      valid_auth
      get '/v2/catalog'
      last_response
      expect(last_response).to be_ok

      body = JSON.parse(last_response.body)
      expect(last_response.status).to eq(200)
      expect(body['services']).to_not be_nil
      expect(body['services'].first['plans'].length).to eq(2)
    end

    it 'returns empty body with incorrect auth given' do
      invalid_auth
      get '/v2/catalog'
      expect(last_response.status).to eq(401)
      expect(last_response).to_not be_ok
      expect(last_response.body).to be_empty
    end
  end

  describe '/v2/service_instances/:id' do
    it 'returns success for "provisioning" a service instance id' do
      allow(Teamserver).to receive(:provision).and_return(Response.new(201))

      valid_auth
      put "/v2/service_instances/#{service_instance_id}", { plan_id: '00000000-1111-2222-3333-000000000000' }

      data = JSON.parse(last_response.body)
      expect(data['dashboard_url']).to eq('https://teamserver.example.com/dashboard/00000000-1111-2222-3333-000000000000')
      expect(last_response.status).to eq(201)
      expect(JSON.parse(last_response.body)).to_not be_empty
    end

    it 'returns success for deleting a service instance id' do
      allow(Teamserver).to receive(:unprovision).and_return({ success: true })

      valid_auth
      delete "/v2/service_instances/#{service_instance_id}", { plan_id: '00000000-1111-2222-3333-000000000000' }

      data = JSON.parse(last_response.body)
      expect(data).to eq({})
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to be_empty
    end

    it 'returns failure when plan id not present' do
      allow(Teamserver).to receive(:unprovision).and_return({ success: true })

      valid_auth
      delete "/v2/service_instances/#{service_instance_id}", { wrong_plan_id: nil }

      data = JSON.parse(last_response.body)
      expect(data['description']).to eq('Invalid plan_id')
      expect(last_response.status).to eq(400)
    end

    it 'returns failure  - incorrect auth given' do
      invalid_auth
      put "/v2/service_instances/#{service_instance_id}", { plan_id: '00000000-1111-2222-3333-000000000000' }
      expect(last_response.status).to eq(401)

      expect(last_response.body).to eq('')

      delete "/v2/service_instances/#{service_instance_id}", { plan_id: '00000000-1111-2222-3333-000000000000' }
      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq('')
    end
  end

  describe '/v2/service_instances/:instance_id/service_bindings/:id' do
    it 'returns a credential for "binding" a service instance' do
      allow(Teamserver).to receive(:bind).and_return(Response.new(201))
      valid_auth
      put "/v2/service_instances/#{service_instance_id}/service_bindings/123", {
        plan_id: '00000000-1111-2222-3333-000000000000'
      }

      expect(last_response.status).to eq(200)
      result = JSON.parse(last_response.body)

      expect(result).to be_a(Hash)

      creds = result['credentials']
      expect(creds).to be_a(Hash)
      expect(creds.size).to eq(9)

      expect(creds['teamserver_url']).to eq('https://app.contrastsecurity.com')
      expect(creds['username']).to eq('agent-00000000-1111-2222-3333-000000000000@contrastsecurity')
      expect(creds['api_key']).to eq('demo')
      expect(creds['service_key']).to eq('demo')
      expect(creds['org_uuid']).to eq('00000000-1111-2222-3333-000000000000')
    end

    it 'not returning success for deleting a binding' do
      valid_auth
      delete "/v2/service_instances/#{service_instance_id}/service_bindings/123", {
        plan_id: '00000000-1111-2222-3333-000000000000'
      }

      expect(last_response.status).to eq(200)
      data = JSON.parse(last_response.body)
      expect(data).to eq({})
    end

    it 'returns failure  - incorrect auth given' do
      invalid_auth
      put "/v2/service_instances/#{service_instance_id}/service_bindings/123", {
        plan_id: '00000000-1111-2222-3333-000000000000'
      }
      expect(last_response.status).to eq(401)

      delete "/v2/service_instances/#{service_instance_id}/service_bindings/123", {
        plan_id: '00000000-1111-2222-3333-000000000000'
      }
      expect(last_response.status).to eq(401)
    end
  end

  describe 'last_operation' do
    it 'returns failure  - incorrect auth given' do
      invalid_auth
      put "/v2/service_instances/#{service_instance_id}/last_operation"
      expect(last_response.status).to eq(401)
    end

    it 'returns success  - correct auth given' do
      valid_auth
      get "/v2/service_instances/#{service_instance_id}/last_operation"
      expect(JSON.parse(last_response.body)).to eq({ 'state' => 'succeeded' })
      expect(last_response.status).to eq(200)
    end
  end

  private

  def valid_auth
    basic_authorize ENV['SECURITY_USER_NAME'], ENV['SECURITY_USER_PASSWORD']
  end

  def invalid_auth
    basic_authorize 'bad', 'bad'
  end
end
