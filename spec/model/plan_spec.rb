require 'spec_helper'

describe Model::Plan do
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
