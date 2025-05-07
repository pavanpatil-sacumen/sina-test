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

require 'sinatra'
require 'net/http'
require 'uri'
require 'base64'
# require_relative 'lib/host_authorization'

class SBApp < Sinatra::Base
	use Rack::JSONBodyParser # middleware so we can get post body data via 'params' variable

	# Enable logging(In Pivotal we want to log to STDOUT so loggregator can consume)
  configure :production, :development do
    enable :logging
    # use HostAuthorization, ['apptwo.contrastsecurity.com', 'localhost:4567']
    # use HostAuthorization, ['localhost', 'apptwo.contrastsecurity.com', 'example.org']
  end

  # configure :test do
	#   disable :protection  # If using Sinatra's built-in protection
	# end

  # Setup Basic Auth - In Pivotal environment variables will be bound to the application for auth
  use Rack::Auth::Basic do |username, password|
    username == ENV['SECURITY_USER_NAME'] && password == ENV['SECURITY_USER_PASSWORD']
  end

  # before do
  # 	byebug
	#   if settings.environment == :test
	#     allowed_hosts = ['apptwo.contrastsecurity.com', 'localhost:4567']
	#     halt 403, 'Host not permitted' unless allowed_hosts.include?(request.host)
	#   end
	# end

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

  get '/notifications/count' do
  	content_type :json

	  # Your actual credentials
	  username = ENV['CONTRAST_USERNAME']
	  service_key = ENV['CONTRAST_SERVICE_KEY']

	  # Encode credentials as Base64 (like btoa in Node)
  	auth_string = Base64.strict_encode64("#{username}:#{service_key}")

  	# API URL
	  api_url = "https://apptwo.contrastsecurity.com/Contrast/api/ng/969321ad-da28-4c8a-9bac-18ca5553b301/notifications/count/new?expand=skip_links"
	  uri = URI(api_url)

	  # Set up the request
	  req = Net::HTTP::Get.new(uri)
	  req['Authorization'] = "Basic #{auth_string}"
	  req['API-Key'] = "YBw9HdoM31pDFz6ziFRmy7vGT47BoL30"
	  req['Accept'] = 'application/json'

	  # Make the HTTP call
	  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
	    http.request(req)
	  end

	  # Parse and return response
	  if res.is_a?(Net::HTTPSuccess)
	    body = JSON.parse(res.body)
	    { success: true, count: body["count"] }.to_json
	  else
	    status res.code.to_i
	    { success: false, error: "Failed to fetch notifications" }.to_json
	  end
  end
end
