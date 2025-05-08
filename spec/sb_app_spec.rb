require 'spec_helper'

describe 'SBApp' do
  class Response
    attr_reader :code
    def initialize c
      @code = c
    end
  end

  let(:service_instance_id){
    '00000000-1111-2222-3333-000000000000'
  }

  describe '/v2/catalog' do
    it 'returns catalog with correct auth given' do
      basic_authorize ENV['SECURITY_USER_NAME'], ENV['SECURITY_USER_PASSWORD']
      get '/v2/catalog', {}, { 'HTTP_HOST' => 'http://59b26d82.ngrok.io' }
      body = JSON.parse(last_response.body)
      expect(body['services']).to_not be_nil
      expect(body['services'].first['plans'].length).to eq(2)
      expect(last_response).to be_ok
    end

    it 'returns empty body with incorrect auth given' do
      basic_authorize 'bad', 'bad'
      get '/v2/catalog'
      expect(last_response).to_not be_ok
      expect(last_response.body).to be_empty
    end
  end

  describe '/v2/service_instances/:id' do
    it 'returns success for "provisioning" a service instance id' do
      allow(Teamserver).to receive(:provision).and_return(Response.new(201))

      basic_authorize ENV['SECURITY_USER_NAME'], ENV['SECURITY_USER_PASSWORD']
      put "/v2/service_instances/#{service_instance_id}",{plan_id: '00000000-1111-2222-3333-000000000000'}

      expect(last_response.status).to eq(201)
      expect(JSON.parse(last_response.body)).to be_empty
    end

    it 'returns success for deleting a service instance id' do
      allow(Teamserver).to receive(:unprovision).and_return({success: true})

      basic_authorize ENV['SECURITY_USER_NAME'], ENV['SECURITY_USER_PASSWORD']
      delete "/v2/service_instances/#{service_instance_id}",{plan_id: '00000000-1111-2222-3333-000000000000'}

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to be_empty
    end

    it 'returns failure  - incorrect auth given' do
      basic_authorize 'bad', 'bad'
      put "/v2/service_instances/#{service_instance_id}",{plan_id: '00000000-1111-2222-3333-000000000000'}
      expect(last_response.status).to eq(401)

      delete "/v2/service_instances/#{service_instance_id}",{plan_id: '00000000-1111-2222-3333-000000000000'}
      expect(last_response.status).to eq(401)
    end
  end

  describe '/v2/service_instances/:instance_id/service_bindings/:id' do
    it 'returns a credential for "binding" a service instance' do
      allow(Teamserver).to receive(:bind).and_return(Response.new(201))
      basic_authorize ENV['SECURITY_USER_NAME'], ENV['SECURITY_USER_PASSWORD']
      put "/v2/service_instances/#{service_instance_id}/service_bindings/123",{plan_id: '00000000-1111-2222-3333-000000000000'}

      expect(last_response.status).to eq(200)
      result = JSON.parse(last_response.body)

      expect(result).to be_a(Hash)

      creds = result['credentials']
      expect(creds).to be_a(Hash)
      expect(creds.size).to eq(5)

      expect(creds['teamserver_url']).to eq('https://app.contrastsecurity.com')
      expect(creds['username']).to eq('agent-00000000-1111-2222-3333-000000000000@contrastsecurity')
      expect(creds['api_key']).to eq('demo')
      expect(creds['service_key']).to eq('demo')
      expect(creds['org_uuid']).to eq('00000000-1111-2222-3333-000000000000')
    end

    it 'returns success for deleting a binding' do

      basic_authorize ENV['SECURITY_USER_NAME'], ENV['SECURITY_USER_PASSWORD']
      delete "/v2/service_instances/#{service_instance_id}/service_bindings/123", {plan_id: '00000000-1111-2222-3333-000000000000'}

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to be_empty
    end

    it 'returns failure  - incorrect auth given' do
      basic_authorize 'bad', 'bad'
      put "/v2/service_instances/#{service_instance_id}/service_bindings/123", {plan_id: '00000000-1111-2222-3333-000000000000'}
      expect(last_response.status).to eq(401)

      delete "/v2/service_instances/#{service_instance_id}/service_bindings/123", {plan_id: '00000000-1111-2222-3333-000000000000'}
      expect(last_response.status).to eq(401)
    end
  end

  describe 'GET /notifications/count' do
    it 'returns success and the notification count' do
      basic_authorize ENV['SECURITY_USER_NAME'], ENV['SECURITY_USER_PASSWORD']
      get '/notifications/count', {}, { 'HTTP_HOST' => 'https://apptwo.contrastsecurity.com' }
      expect(last_response).to be_ok
      data = JSON.parse(last_response.body)
      expect(data['success']).to eq true
      expect(data['count']).to be_a(Numeric)
    end
  end

  describe 'GET /notifications/expand' do
    it 'returns success and expand the notifications data' do
      basic_authorize ENV['SECURITY_USER_NAME'], ENV['SECURITY_USER_PASSWORD']
      get '/notifications/expand', {}, { 'HTTP_HOST' => 'https://apptwo.contrastsecurity.com' }
      expect(last_response).to be_ok
      data = JSON.parse(last_response.body)
      expect(data['success']).to eq true
      expect(data["data"]["messages"].first).to eq "Notifications loaded successfully"
      expect(data["data"]["notifications"]).not_to be_nil
    end
  end

  describe 'PUT /notifications/read' do
    it 'returns success and update the notifications as read value true' do
      basic_authorize ENV['SECURITY_USER_NAME'], ENV['SECURITY_USER_PASSWORD']
      put '/notifications/read', {}, { 'HTTP_HOST' => 'https://apptwo.contrastsecurity.com' }
      expect(last_response).to be_ok
      data = JSON.parse(last_response.body)
      expect(data['success']).to eq true
      expect(data["data"]["messages"].first).to eq "Notifications status updated successfully"
    end
  end
end
