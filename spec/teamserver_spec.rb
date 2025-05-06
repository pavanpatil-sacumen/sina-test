require 'spec_helper'

describe Teamserver do
  describe 'helpers' do
    let(:credential){
      cred = Model::Credential.new
      cred.username = 'agent-00000000-1234-1234-1234-1234567890ab@contrastsecurity'
      cred.service_key = 'YK13LA49HSD1U'
      cred.api_key = 'demo'
      cred.teamserver_url = 'https://app.contrastsecurity.com'
      cred.org_uuid = '00000000-1234-1234-1234-1234567890ab'
      cred
    }

    let(:service_instance_id){
      'f78a7694-0835-11e8-ba89-0ed5f89f718b'
    }

    it 'can build correct Authorization value' do
      auth = Teamserver.build_authorization(credential)
      expect(auth).to eq('YWdlbnQtMDAwMDAwMDAtMTIzNC0xMjM0LTEyMzQtMTIzNDU2Nzg5MGFiQGNvbnRyYXN0c2VjdXJpdHk6WUsxM0xBNDlIU0QxVQ==')
    end

    it 'can build correct headers' do
      headers = Teamserver.build_headers(credential)
      expect(headers).to be_a(Hash)
      expect(headers.keys.length).to eq(3)
      expect(headers[:'API-Key']).to eq('demo')
      expect(headers[:Authorization]).to eq('YWdlbnQtMDAwMDAwMDAtMTIzNC0xMjM0LTEyMzQtMTIzNDU2Nzg5MGFiQGNvbnRyYXN0c2VjdXJpdHk6WUsxM0xBNDlIU0QxVQ==')
      expect(headers[:'Content-Type']).to eq('application/json')
    end

    it 'can build a correct URL with / at end' do
      teamserver_url = 'https://app.contrastsecurity.com/'
      result = Teamserver.build_url(teamserver_url, "/instances/#{service_instance_id}")
      expect(result).to eq('https://app.contrastsecurity.com/Contrast/api/ng/pivotal/instances/f78a7694-0835-11e8-ba89-0ed5f89f718b')
    end

    it 'can build a correct URL without / at end' do
      teamserver_url = 'https://app.contrastsecurity.com'
      result = Teamserver.build_url(teamserver_url, "/instances/#{service_instance_id}")
      expect(result).to eq('https://app.contrastsecurity.com/Contrast/api/ng/pivotal/instances/f78a7694-0835-11e8-ba89-0ed5f89f718b')
    end
  end

  describe 'building the proxy' do
   describe 'with no proxy and blank proxy info' do
    let(:credential){
      cred = Model::Credential.new
      cred.username = 'agent-00000000-1234-1234-1234-1234567890ab@contrastsecurity'
      cred.service_key = 'YK13LA49HSD1U'
      cred.api_key = 'demo'
      cred.teamserver_url = 'https://app.contrastsecurity.com'
      cred.org_uuid = '00000000-1234-1234-1234-1234567890ab'
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
      cred.username = 'agent-00000000-1234-1234-1234-1234567890ab@contrastsecurity'
      cred.service_key = 'YK13LA49HSD1U'
      cred.api_key = 'demo'
      cred.teamserver_url = 'https://app.contrastsecurity.com'
      cred.org_uuid = '00000000-1234-1234-1234-1234567890ab'
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
      cred.username = 'agent-00000000-1234-1234-1234-1234567890ab@contrastsecurity'
      cred.service_key = 'YK13LA49HSD1U'
      cred.api_key = 'demo'
      cred.teamserver_url = 'https://app.contrastsecurity.com'
      cred.org_uuid = '00000000-1234-1234-1234-1234567890ab'
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
      cred.username = 'agent-00000000-1234-1234-1234-1234567890ab@contrastsecurity'
      cred.service_key = 'YK13LA49HSD1U'
      cred.api_key = 'demo'
      cred.teamserver_url = 'https://app.contrastsecurity.com'
      cred.org_uuid = '00000000-1234-1234-1234-1234567890ab'
      cred.proxy_host = 'http://example.com'
      cred.proxy_port = '20202'
      cred.proxy_user = ''
      cred.proxy_pass = ''
      cred
    } 

    let(:options) {
      Hash.new
    }   

    it 'does not modify options' do
      actual_options = Teamserver.build_proxy options, credential
      expect(actual_options[:http_proxyaddr]).to eq "http://example.com"
      expect(actual_options[:http_proxyport]).to eq "20202"
      expect(actual_options).not_to have_key(:http_proxyuser)
      expect(actual_options).not_to have_key(:http_proxypass)
    end
   end

   describe 'with proxy info' do
    let(:credential){
      cred = Model::Credential.new
      cred.username = 'agent-00000000-1234-1234-1234-1234567890ab@contrastsecurity'
      cred.service_key = 'YK13LA49HSD1U'
      cred.api_key = 'demo'
      cred.teamserver_url = 'https://app.contrastsecurity.com'
      cred.org_uuid = '00000000-1234-1234-1234-1234567890ab'
      cred.proxy_host = 'http://example.com'
      cred.proxy_port = '20202'
      cred.proxy_user = 'ausername'
      cred.proxy_pass = 'apassword'
      cred
    } 

    let(:options) {
      Hash.new
    }   

    it 'does not modify options' do
      actual_options = Teamserver.build_proxy options, credential
      expect(actual_options[:http_proxyaddr]).to eq "http://example.com"
      expect(actual_options[:http_proxyport]).to eq "20202"
      expect(actual_options[:http_proxyuser]).to eq "ausername"
      expect(actual_options[:http_proxypass]).to eq nil
    end
   end
  end

  describe 'endpoints' do
    let(:credential){
      cred = Model::Credential.new
      cred.username = 'agent-00000000-1234-1234-1234-1234567890ab@contrastsecurity'
      cred.service_key = 'YK13LA49HSD1U'
      cred.api_key = 'demo'
      cred.teamserver_url = 'https://app.contrastsecurity.com'
      cred.org_uuid = '00000000-1234-1234-1234-1234567890ab'
      cred
    }

    let(:service_instance_id){
      'f78a7694-0835-11e8-ba89-0ed5f89f718b'
    }

    it 'can build appropriate provisioning request' do
      allow(HTTParty).to receive(:post).with(anything).and_return({success: true})
      # expect(HTTParty).to receive(:post).with('https://app.contrastsecurity.com/Contrast/api/ng/pivotal/instances/f78a7694-0835-11e8-ba89-0ed5f89f718b', :body => {organizationUuid: credential.org_uuid}.to_json, :headers => anything)
      # Teamserver.provision(service_instance_id, credential)
    end

    it 'can build appropriate binding request' do
      allow(HTTParty).to receive(:post).with(anything).and_return({success: true})
      # expect(HTTParty).to receive(:post).with('https://app.contrastsecurity.com/Contrast/api/ng/pivotal/instances/f78a7694-0835-11e8-ba89-0ed5f89f718b/bindings/1',:body => {organizationUuid: credential.org_uuid}.to_json, :headers => anything)
      # Teamserver.bind(service_instance_id,'1', credential)
    end

    it 'can build appropriate unprovisioning request' do
      allow(HTTParty).to receive(:delete).with(anything).and_return({success: true})
      # expect(HTTParty).to receive(:delete).with('https://app.contrastsecurity.com/Contrast/api/ng/pivotal/instances/f78a7694-0835-11e8-ba89-0ed5f89f718b', :headers => anything)
      # Teamserver.unprovision(service_instance_id, credential)
    end
  end
end
