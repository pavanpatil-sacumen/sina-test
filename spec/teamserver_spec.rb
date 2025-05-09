require 'spec_helper'

describe Teamserver do
  describe 'helpers' do
    let(:credential){
      cred = Model::Credential.new
      cred.username = ENV['USERNAME4']
      cred.service_key = ENV['SERVICE_KEY_3']
      cred.api_key = ENV['API_KEY']
      cred.teamserver_url = ENV['NG_HOST']
      cred.org_uuid = ENV['ORG_UUID_4']
      cred
    }

    let(:service_instance_id){
      ENV['SERVICE_INSTANCE_ID_2']
    }

    APPLICATION_J = 'application/json'.freeze

    it 'can build correct Authorization value' do
      auth = Teamserver.build_authorization(credential)
      expect(auth).to eq(ENV['AUTH_T'])
    end

    it 'can build correct headers' do
      headers = Teamserver.build_headers(credential)
      expect(headers).to be_a(Hash)
      expect(headers.keys.length).to eq(3)
      expect(headers[:'API-Key']).to eq(ENV['API_KEY'])
      expect(headers[:Authorization]).to eq(ENV['AUTH_T'])
      expect(headers[:'Content-Type']).to eq(APPLICATION_J)
    end

    it 'can build a correct URL with / at end' do
      teamserver_url = ENV['TEAMSERVER_URL2']
      result = Teamserver.build_url(teamserver_url, "/instances/#{service_instance_id}")
      expect(result).to eq(ENV['RES_URL'])
    end

    it 'can build a correct URL without / at end' do
      teamserver_url = 'https://app.contrastsecurity.com'
      result = Teamserver.build_url(teamserver_url, "/instances/#{service_instance_id}")
      expect(result).to eq(ENV['RES_URL'])
    end
  end

  describe 'building the proxy' do
   describe 'with no proxy and blank proxy info' do
    let(:credential){
      cred = Model::Credential.new
      cred.username = ENV['USERNAME5']
      cred.service_key = ENV['SERVICE_KEY_4']
      cred.api_key = ENV['API_KEY_D']
      cred.teamserver_url = ENV['TEAMSERVER_URL']
      cred.org_uuid = ENV['ORG_UUID_5']
      cred.proxy_host = ''
      cred.proxy_port = ''
      cred.proxy_user = ''
      cred.proxy_pass = ''
      cred
    } 

    let(:options) {
      Hash.new
    }   

    it 'does not modify options' do
      actual_options = Teamserver.build_proxy options, credential
      expect(actual_options).not_to have_key(:http_proxyaddr)
      expect(actual_options).not_to have_key(:http_proxyport)
      expect(actual_options).not_to have_key(:http_proxyuser)
      expect(actual_options).not_to have_key(:http_proxypass)
    end
   end 
  
   describe 'with no proxy and missing proxy info' do
    let(:credential){
      cred = Model::Credential.new
      cred.username = ENV['USERNAME5']
      cred.service_key = ENV['SERVICE_KEY_4']
      cred.api_key = ENV['API_KEY_D']
      cred.teamserver_url = ENV['TEAMSERVER_URL']
      cred.org_uuid = ENV['ORG_UUID_5']
      cred
    } 

    let(:options) {
      Hash.new
    }   

    it 'does not modify options' do
      actual_options = Teamserver.build_proxy options, credential
      expect(actual_options).not_to have_key(:http_proxyaddr)
      expect(actual_options).not_to have_key(:http_proxyport)
      expect(actual_options).not_to have_key(:http_proxyuser)
      expect(actual_options).not_to have_key(:http_proxypass)
    end
   end
  
   describe 'with no proxy and nil proxy info' do
    let(:credential){
      cred = Model::Credential.new
      cred.username = ENV['USERNAME5']
      cred.service_key = ENV['SERVICE_KEY_4']
      cred.api_key = ENV['API_KEY_D']
      cred.teamserver_url = ENV['TEAMSERVER_URL']
      cred.org_uuid = ENV['ORG_UUID_5']
      cred.proxy_host = nil
      cred.proxy_port = nil
      cred.proxy_user = nil
      cred.proxy_pass = nil
      cred
    } 

    let(:options) {
      Hash.new
    }   

    it 'does not modify options' do
      actual_options = Teamserver.build_proxy options, credential
      expect(actual_options).not_to have_key(:http_proxyaddr)
      expect(actual_options).not_to have_key(:http_proxyport)
      expect(actual_options).not_to have_key(:http_proxyuser)
      expect(actual_options).not_to have_key(:http_proxypass)
    end
   end

   describe 'with no authentication' do
    let(:credential){
      cred = Model::Credential.new
      cred.username = ENV['USERNAME5']
      cred.service_key = ENV['SERVICE_KEY_4']
      cred.api_key = ENV['API_KEY_D']
      cred.teamserver_url = ENV['TEAMSERVER_URL']
      cred.org_uuid = ENV['ORG_UUID_5']
      cred.proxy_host = ENV['PRO_HOST']
      cred.proxy_port = ENV['PRO_PORT']
      cred.proxy_user = ''
      cred.proxy_pass = ''
      cred
    } 

    let(:options) {
      Hash.new
    }   

    it 'does not modify options' do
      actual_options = Teamserver.build_proxy options, credential
      expect(actual_options[:http_proxyaddr]).to eq ENV['PRO_HOST']
      expect(actual_options[:http_proxyport]).to eq ENV['PRO_PORT']
      expect(actual_options).not_to have_key(:http_proxyuser)
      expect(actual_options).not_to have_key(:http_proxypass)
    end
   end

   describe 'with proxy info' do
    let(:credential){
      cred = Model::Credential.new
      cred.username = ENV['USERNAME5']
      cred.service_key = ENV['SERVICE_KEY_4']
      cred.api_key = ENV['API_KEY_D']
      cred.teamserver_url = ENV['TEAMSERVER_URL']
      cred.org_uuid = ENV['ORG_UUID_5']
      cred.proxy_host = ENV['PRO_HOST']
      cred.proxy_port = ENV['PRO_PORT']
      cred.proxy_user = ENV['PRO_USER']
      cred.proxy_pass = ENV['PRO_PASS']
      cred
    } 

    let(:options) {
      Hash.new
    }   

    it 'does not modify options' do
      actual_options = Teamserver.build_proxy options, credential
      expect(actual_options[:http_proxyaddr]).to eq ENV['PRO_HOST']
      expect(actual_options[:http_proxyport]).to eq ENV['PRO_PORT']
      expect(actual_options[:http_proxyuser]).to eq nil
      expect(actual_options[:http_proxypass]).to eq nil
    end
   end
  end

  describe 'endpoints' do
    let(:credential){
      cred = Model::Credential.new
      cred.username = ENV['USERNAME5']
      cred.service_key = ENV['SERVICE_KEY_4']
      cred.api_key = ENV['API_KEY']
      cred.teamserver_url = ENV['NG_HOST']
      cred.org_uuid = ENV['ORG_UUID_4']
      cred
    }

    let(:service_instance_id){
      ENV['SERVICE_INSTANCE_ID_2']
    }

    it 'can build appropriate provisioning request' do
      allow(HTTParty).to receive(:post).and_return({success: true})
      expect(HTTParty).to receive(:post)
      Teamserver.provision(service_instance_id, credential)
    end

    it 'can build appropriate binding request' do
      allow(HTTParty).to receive(:post).and_return({success: true})
      expect(HTTParty).to receive(:post)
      Teamserver.bind(service_instance_id,'1', credential)
    end

    it 'can build appropriate unprovisioning request' do
      allow(HTTParty).to receive(:delete).and_return({success: true})
      expect(HTTParty).to receive(:delete)
      Teamserver.unprovision(service_instance_id, credential)
    end
  end
end
