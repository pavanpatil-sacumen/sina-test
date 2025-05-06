require 'spec_helper'

describe Catalog do
  describe 'build' do

    it 'can be instantiated' do
      expect(Catalog.instance).to_not be_nil
    end

    it 'builds the catalog with the plans from the environment' do
      instance = Catalog.instance
      plans = instance.catalog['services'].first['plans']

      expect(plans.length).to eq(2)
      expect(plans[0].name).to eq('ServicePlan1')
      expect(plans[0].id).to eq('00000000-1111-2222-3333-000000000000')

      expect(plans[1].name).to eq('ServicePlan2')
      expect(plans[1].id).to eq('zzzzzzzz-1111-2222-3333-000000000000')
    end

    it 'builds plans with correct credentials' do
      instance = Catalog.instance
      plans = instance.catalog['services'].first['plans']

      expect(plans.length).to eq(2)
      cred1 = plans[0].credentials
      expect(cred1.api_key).to eq('demo')
      expect(cred1.org_uuid).to eq('00000000-1111-2222-3333-000000000000')
      expect(cred1.service_key).to eq('demo')
      expect(cred1.teamserver_url).to eq('https://app.contrastsecurity.com')
      expect(cred1.username).to eq('agent-00000000-1111-2222-3333-000000000000@contrastsecurity')

      cred2 = plans[1].credentials
      expect(cred2.api_key).to eq('zzzz')
      expect(cred2.org_uuid).to eq('zzzzzzzz-1111-2222-3333-000000000000')
      expect(cred2.service_key).to eq('service_zzzz')
      expect(cred2.teamserver_url).to eq('https://alpha.contrastsecurity.com')
      expect(cred2.username).to eq('agent-zzzzzzzz-1111-2222-3333-000000000000@contrastsecurity')
    end
  end
end
