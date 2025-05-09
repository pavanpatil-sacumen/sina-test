require 'spec_helper'

describe Model::Plan do
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
      plan = Model::Plan.from_hash(hash)

      expect(plan).to_not be_nil
      expect(plan.id).to eq(hash['org_uuid'])
      expect(plan.name).to eq(hash['name'])
      expect(plan.description).to eq(Model::Plan::DESCRIPTION)

      expect(plan.metadata).to be_a(Hash)
      expect(plan.metadata[:bullets]).to be_a(Array)
      expect(plan.metadata[:bullets].length).to eq(3)
    end
  end
end
