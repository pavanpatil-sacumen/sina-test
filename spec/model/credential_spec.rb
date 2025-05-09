require 'spec_helper'

describe Model::Credential do
  describe 'basics' do

    let(:hash){
      {
        'name' => ENV['SERVICEPLAN1'],
        'teamserver_url' => ENV['TEAMSERVER_URL'],
        'username' => ENV['USERNAME'],
        'api_key' => ENV['API_KEY_D'],
        'service_key' => ENV['SERVICE_KEY_D'],
        'org_uuid' => ENV['ORG_UUID']
      }
    }

    it 'can be built from a hash' do
      credential = Model::Credential.from_hash(hash)

      expect(credential).to_not be_nil
      expect(credential.api_key).to eq(ENV['API_KEY_D'])
      expect(credential.org_uuid).to eq(ENV['ORG_UUID'])
      expect(credential.service_key).to eq(ENV['SERVICE_KEY_D'])
      expect(credential.teamserver_url).to eq(ENV['TEAMSERVER_URL'])
      expect(credential.username).to eq(ENV['USERNAME'])
    end

    it 'returns valid JSON' do
      credential = Model::Credential.from_hash(hash)
      json = credential.to_json

      hash = JSON.parse(json)

      expect(hash).to_not be_nil
      expect(hash['api_key']).to eq(ENV['API_KEY_D'])
      expect(hash['org_uuid']).to eq(ENV['ORG_UUID'])
      expect(hash['service_key']).to eq(ENV['SERVICE_KEY_D'])
      expect(hash['teamserver_url']).to eq(ENV['TEAMSERVER_URL'])
      expect(hash['username']).to eq(ENV['USERNAME'])
    end
  end
end
