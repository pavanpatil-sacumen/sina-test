require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'   # or '/test/', depending on your test folder
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))

require 'json'
require 'sb_app'
require 'rack/test'
require 'rspec'
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'

WebMock.disable_net_connect!(allow_localhost: false)

module RSpecMixin
  include Rack::Test::Methods
  def app() SBApp.new end
end

RSpec.configure do |config|
	config.include RSpecMixin

  service_plans_env = {
    :ServicePlan1 => {
      :name => 'ServicePlan1',
      :teamserver_url => 'https://app.contrastsecurity.com',
      :username => 'agent-00000000-1111-2222-3333-000000000000@contrastsecurity',
      :api_key => 'demo',
      :service_key => 'demo',
      :org_uuid => '00000000-1111-2222-3333-000000000000'
    },
    :ServicePlan2 => {
      :name => 'ServicePlan2',
      :teamserver_url => 'https://alpha.contrastsecurity.com',
      :username => 'agent-zzzzzzzz-1111-2222-3333-000000000000@contrastsecurity',
      :api_key => 'zzzz',
      :service_key => 'service_zzzz',
      :org_uuid => 'zzzzzzzz-1111-2222-3333-000000000000'
    }
  }

  ENV['CONTRAST_SERVICE_PLANS'] = service_plans_env.to_json
  ENV['SECURITY_USER_NAME'] = 'TEST_USER'
  ENV['SECURITY_USER_PASSWORD'] = 'TEST_PASSWORD'
  ENV['CONTRAST_USERNAME'] = 'pavan.patil@sacumen.com'
  ENV['CONTRAST_SERVICE_KEY'] = 'ADORTRKUUKL15YNU'
  config.before(:suite) do
    SBApp.middleware.delete_if { |m| m[0] == HostAuthorization }
  end
end
