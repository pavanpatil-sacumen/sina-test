$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))
require 'json'
require 'service_broker_app'
require 'rack/test'

module RSpecMixin
  include Rack::Test::Methods
  def app() ServiceBrokerApp.new end
end

RSpec.configure do |config|

  config.include RSpecMixin

  # Service Plans
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

end
