require 'spec_helper'

describe Model::Credential do
  describe 'basics' do

    let(:hash){
      {
        'name' => 'ServicePlan1',
        'teamserver_url' => 'https://app.contrastsecurity.com',
        'username' => 'agent-00000000-1111-2222-3333-000000000000@contrastsecurity',
        'api_key' => 'demo',
        'service_key' => 'demo',
        'org_uuid' => '00000000-1111-2222-3333-000000000000'
      }
    }

    it 'can be built from a hash' do
      credential = Model::Credential.from_hash(hash)

      expect(credential).to_not be_nil
      expect(credential.api_key).to eq('demo')
      expect(credential.org_uuid).to eq('00000000-1111-2222-3333-000000000000')
      expect(credential.service_key).to eq('demo')
      expect(credential.teamserver_url).to eq('https://app.contrastsecurity.com')
      expect(credential.username).to eq('agent-00000000-1111-2222-3333-000000000000@contrastsecurity')
    end

    it 'returns valid JSON' do
      credential = Model::Credential.from_hash(hash)
      json = credential.to_json

      hash = JSON.parse(json)

      expect(hash).to_not be_nil
      expect(hash['api_key']).to eq('demo')
      expect(hash['org_uuid']).to eq('00000000-1111-2222-3333-000000000000')
      expect(hash['service_key']).to eq('demo')
      expect(hash['teamserver_url']).to eq('https://app.contrastsecurity.com')
      expect(hash['username']).to eq('agent-00000000-1111-2222-3333-000000000000@contrastsecurity')
    end

  end
end