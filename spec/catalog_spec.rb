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
      expect(plans[0].name).to eq(ENV['SERVICEPLAN1'])
      expect(plans[0].id).to eq(ENV['ORG_UUID'])

      expect(plans[1].name).to eq(ENV['SERVICEPLAN2'])
      expect(plans[1].id).to eq(ENV['ORG_UUID2'])
    end

    it 'builds plans with correct credentials' do
      instance = Catalog.instance
      plans = instance.catalog['services'].first['plans']

      expect(plans.length).to eq(2)
      cred1 = plans[0].credentials
      expect(cred1.api_key).to eq(ENV['API_KEY_D'])
      expect(cred1.org_uuid).to eq(ENV['ORG_UUID'])
      expect(cred1.service_key).to eq(ENV['SERVICE_KEY_D'])
      expect(cred1.teamserver_url).to eq(ENV['TEAMSERVER_URL'])
      expect(cred1.username).to eq(ENV['USERNAME2'])

      cred2 = plans[1].credentials
      expect(cred2.api_key).to eq(ENV['API_KEY_2'])
      expect(cred2.org_uuid).to eq(ENV['ORG_UUID2'])
      expect(cred2.service_key).to eq(ENV['SERVICE_KEY_2'])
      expect(cred2.teamserver_url).to eq(ENV['TEAMSERVER_URL_2'])
      expect(cred2.username).to eq(ENV['USERNAME3'])
    end
  end
end
