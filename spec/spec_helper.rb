require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))

require 'json'
require 'sb_app'
require 'rack/test'
require 'rspec'
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ['apptwo.contrastsecurity.com']
)

module RSpecMixin
  include Rack::Test::Methods
  def app() SBApp.new end
end

RSpec.configure do |config|
	config.include RSpecMixin

  service_plans_env = {
    :ServicePlan1 => {
      :name => ENV['SERVICEPLAN1'],
      :teamserver_url => ENV['TEAMSERVER_URL'],
      :username => ENV['USERNAME2'],
      :api_key => ENV['API_KEY_D'],
      :service_key => ENV['SERVICE_KEY_D'],
      :org_uuid => ENV['ORG_UUID']
    },
    :ServicePlan2 => {
      :name => ENV['SERVICEPLAN2'],
      :teamserver_url => ENV['TEAMSERVER_URL_2'],
      :username => ENV['USERNAME3'],
      :api_key => ENV['API_KEY_2'],
      :service_key => ENV['SERVICE_KEY_2'],
      :org_uuid => ENV['ORG_UUID2']
    }
  }

  ENV['CONTRAST_SERVICE_PLANS'] = service_plans_env.to_json
end
