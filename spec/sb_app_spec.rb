require 'spec_helper'

describe 'SBApp' do
  class Response
    attr_reader :code
    def initialize c
      @code = c
    end
  end

  NOTIFICATIONS_LOADED_S = "Notifications loaded successfully".freeze
  NOTIFICATIONS_STATUS_UPDATED_S = "Notifications status updated successfully".freeze

  let(:service_instance_id){
    ENV['SERVICE_INSTANCE_ID']
  }

  describe '/v2/catalog' do
    it 'returns catalog with correct auth given' do
      valid_auth
      get '/v2/catalog'
      body = JSON.parse(last_response.body)
      expect(body['services']).to_not be_nil
      expect(body['services'].first['plans'].length).to eq(2)
      expect(last_response).to be_ok
    end

    it 'returns empty body with incorrect auth given' do
      invalid_auth
      get '/v2/catalog'
      expect(last_response).to_not be_ok
      expect(last_response.body).to be_empty
    end
  end

  describe '/v2/service_instances/:id' do
    it 'returns success for "provisioning" a service instance id' do
      allow(Teamserver).to receive(:provision).and_return(Response.new(201))

      valid_auth
      put "/v2/service_instances/#{service_instance_id}",{plan_id: ENV['PLAN_ID']}

      expect(last_response.status).to eq(201)
      expect(JSON.parse(last_response.body)).to be_empty
    end

    it 'returns success for deleting a service instance id' do
      allow(Teamserver).to receive(:unprovision).and_return({success: true})

      valid_auth
      delete "/v2/service_instances/#{service_instance_id}",{plan_id: ENV['PLAN_ID']}

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to be_empty
    end

    it 'returns failure  - incorrect auth given' do
      invalid_auth
      put "/v2/service_instances/#{service_instance_id}",{plan_id: ENV['PLAN_ID']}
      expect(last_response.status).to eq(401)

      delete "/v2/service_instances/#{service_instance_id}",{plan_id: ENV['PLAN_ID']}
      expect(last_response.status).to eq(401)
    end
  end

  describe '/v2/service_instances/:instance_id/service_bindings/:id' do
    it 'returns a credential for "binding" a service instance' do
      allow(Teamserver).to receive(:bind).and_return(Response.new(201))
      valid_auth
      put "/v2/service_instances/#{service_instance_id}/service_bindings/123",{plan_id: ENV['PLAN_ID']}

      expect(last_response.status).to eq(200)
      result = JSON.parse(last_response.body)

      expect(result).to be_a(Hash)

      creds = result['credentials']
      expect(creds).to be_a(Hash)
      expect(creds.size).to eq(5)

      expect(creds['teamserver_url']).to eq(ENV['TEAMSERVER_URL'])
      expect(creds['username']).to eq(ENV['USERNAME2'])
      expect(creds['api_key']).to eq(ENV['API_KEY_D'])
      expect(creds['service_key']).to eq(ENV['SERVICE_KEY_D'])
      expect(creds['org_uuid']).to eq(ENV['PLAN_ID'])
    end

    it 'returns success for deleting a binding' do
      valid_auth
      delete "/v2/service_instances/#{service_instance_id}/service_bindings/123", {plan_id: ENV['PLAN_ID']}

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to be_empty
    end

    it 'returns failure  - incorrect auth given' do
      invalid_auth
      put "/v2/service_instances/#{service_instance_id}/service_bindings/123", {plan_id: ENV['PLAN_ID']}
      expect(last_response.status).to eq(401)

      delete "/v2/service_instances/#{service_instance_id}/service_bindings/123", {plan_id: ENV['PLAN_ID']}
      expect(last_response.status).to eq(401)
    end
  end

  describe 'GET /notifications/count' do
    it 'returns success and the notification count' do
      valid_auth
      get '/notifications/count'
      expect(last_response).to be_ok
      data = JSON.parse(last_response.body)
      expect(data['success']).to eq true
      expect(data['count']).to be_a(Numeric)
    end
  end

  describe 'GET /notifications/expand' do
    it 'returns success and expand the notifications data' do
      valid_auth
      get '/notifications/expand'
      expect(last_response).to be_ok
      data = JSON.parse(last_response.body)
      expect(data['success']).to eq true
      expect(data["data"]["messages"].first).to eq NOTIFICATIONS_LOADED_S
      expect(data["data"]["notifications"]).not_to be_nil
    end
  end

  describe 'PUT /notifications/read' do
    it 'returns success and update the notifications as read value true' do
      valid_auth
      put '/notifications/read'
      expect(last_response).to be_ok
      data = JSON.parse(last_response.body)
      expect(data['success']).to eq true
      expect(data["data"]["messages"].first).to eq NOTIFICATIONS_STATUS_UPDATED_S
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
