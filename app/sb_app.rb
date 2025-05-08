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

class SBApp < Sinatra::Base
	puts "Running ruby version: #{RUBY_VERSION}"
	puts "Running sinatra version: #{Sinatra::VERSION}"

	use Rack::JSONBodyParser

  configure :production, :development, :test do
    enable :logging
    before do
      allowed = ['http://59b26d82.ngrok.io', 'localhost', 'https://apptwo.contrastsecurity.com', 'example.org']
      halt 403, 'Host not permitted' unless allowed.include?(request.host)
    end
  end

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
  	env_keys

  	api_url_to_uri("https://apptwo.contrastsecurity.com/Contrast/api/ng/969321ad-da28-4c8a-9bac-18ca5553b301/notifications/count/new?expand=skip_links")
	  set_req_headers(@uri)
	  get_a_response_for_req(@req)

	  if @res.is_a?(Net::HTTPSuccess)
	    body = JSON.parse(@res.body)
	    { success: true, count: body["count"] }.to_json
	  else
	    status @res.code.to_i
	    { success: false, error: "Failed to fetch notifications" }.to_json
	  end
  end

  # get '/notifications/expand' do
  # 	content_type :json
  # 	env_keys

	#   api_url_to_uri("https://apptwo.contrastsecurity.com/Contrast/api/ng/969321ad-da28-4c8a-9bac-18ca5553b301/notifications?expand=skip_links&limit=10&offset=0")
	#   set_req_headers(@uri)
	#   get_a_response_for_req(@req)

	#   if @res.is_a?(Net::HTTPSuccess)
	#     body = JSON.parse(@res.body)
	#     { success: true, data: body }.to_json
	#   else
	#     status @res.code.to_i
	#     { success: false, error: "Failed to fetch notifications" }.to_json
	#   end
  # end

  # put '/notifications/read' do
  # 	content_type :json
  # 	env_keys

  # 	api_url_to_uri("https://apptwo.contrastsecurity.com/Contrast/api/ng/969321ad-da28-4c8a-9bac-18ca5553b301/notifications/read")
	#   set_req_headers_put(@uri)
	#   get_a_response_for_req(@req)

	#   if @res.is_a?(Net::HTTPSuccess)
	#     body = JSON.parse(@res.body)
	#     { success: true, data: body }.to_json
	#   else
	#     status @res.code.to_i
	#     { success: false, error: "Failed to fetch notifications" }.to_json
	#   end
  # end

  private

  def env_keys
	  username = ENV['CONTRAST_USERNAME']
	  service_key = ENV['CONTRAST_SERVICE_KEY']

  	@auth_string = Base64.strict_encode64("#{username}:#{service_key}")
  end

  def api_url_to_uri(api_url)
  	@uri = URI(api_url)
  end

  def set_req_headers(uri)
  	@req = Net::HTTP::Get.new(uri)
	  @req['Authorization'] = "Basic #{@auth_string}"
	  @req['API-Key'] = "YBw9HdoM31pDFz6ziFRmy7vGT47BoL30"
	  @req['Accept'] = 'application/json'
	  @req
  end

  def set_req_headers_put(uri)
  	@req = Net::HTTP::Put.new(uri)
	  @req['Authorization'] = "Basic #{@auth_string}"
	  @req['API-Key'] = "YBw9HdoM31pDFz6ziFRmy7vGT47BoL30"
	  @req['Accept'] = 'application/json'
	  @req
  end

  def get_a_response_for_req(req)
  	@res = Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: true) do |http|
	    http.request(@req)
	  end
  end
end
