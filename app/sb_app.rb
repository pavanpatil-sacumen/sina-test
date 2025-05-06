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
    # if response.code == 201 || ENV['CONTRAST_BACKWARDS_COMPAT']
    if response.code == 201
    	status 201
      {}.to_json
    else
      status response.code
      {:description => 'Unable to provision service instance'}.to_json
    end
  end

  delete '/v2/service_instances/:instance_id' do |instance_id|
    content_type :json
    plan_id = params[:plan_id]

    plan = Catalog.instance.find_plan(plan_id)
    logger.info "Unprovision Request Received: Plan: #{plan_id} - Service Instance ID: #{instance_id}"
    Teamserver.unprovision(instance_id, plan.credentials)
    status 200
    {}.to_json
  end

  put '/v2/service_instances/:instance_id/service_bindings/:id' do |instance_id, binding_id|
  	content_type :json

  	plan_id = params[:plan_id]
  	logger.info "Bind Request Received - Plan: #{plan_id}"
    plan = Catalog.instance.find_plan(plan_id)
    res = Teamserver.bind(instance_id, binding_id, plan.credentials)

    if plan
      status 200
      {:credentials => plan.credentials}.to_json
    else
      status 404
      {:msg => 'Service Instance not found'}.to_json
    end
  end

  delete '/v2/service_instances/:instance_id/service_bindings/:id' do |instance_id, binding_id|
    content_type :json
    logger.info 'Unbind Request Received'
    status 200
    {}.to_json
  end
end
