# frozen_string_literal: true

require 'dotenv'
Dotenv.load

lib = File.expand_path('app', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'service_broker_app'

# Use Rack Basic Auth middleware to protect all endpoints
use Rack::Auth::Basic, 'Service Broker' do |username, password|
  expected_user = ENV['SECURITY_USER_NAME']
  expected_pass = ENV['SECURITY_USER_PASSWORD']
  username == expected_user && password == expected_pass
end

run ServiceBrokerApp.new
