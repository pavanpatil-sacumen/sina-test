require 'sinatra'
require 'dotenv/load'
require 'pry'
require 'byebug'
require 'json'
require 'yaml'

require 'model'
require 'catalog'
require 'teamserver'

require 'rack'
require 'rack/contrib'

class SBApp < Sinatra::Base
	use Rack::JSONBodyParser # middleware so we can get post body data via 'params' variable

	# Enable logging(In Pivotal we want to log to STDOUT so loggregator can consume)
  configure :production, :development do
    enable :logging
  end

  # Setup Basic Auth - In Pivotal environment variables will be bound to the application for auth
  use Rack::Auth::Basic do |username, password|
    username == ENV['SECURITY_USER_NAME'] && password == ENV['SECURITY_USER_PASSWORD']
  end

  get '/v2/catalog' do
	  content_type :json
	  logger.info 'Catalog Request Received'
	  Catalog.instance.catalog.to_json
	end

	put '/v2/service_instances/:id' do |id|
		content_type :json
    plan_id = params[:plan_id]

    plan = Catalog.instance.find_plan(plan_id)
    logger.info "Provision Request Received: Plan: #{plan_id} - Service Instance ID: #{id}"
    response = Teamserver.provision(id, plan.credentials)
    if response.code == 201 || ENV['CONTRAST_BACKWARDS_COMPAT']
    	status 201
      {}.to_json
    else
      status response.code
      {:description => 'Unable to provision service instance'}.to_json
    end
  end
end
