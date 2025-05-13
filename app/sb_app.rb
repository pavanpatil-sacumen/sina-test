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
require 'net/http'
require 'uri'
require 'base64'

class SBApp < Sinatra::Base
	puts "Running ruby version: #{RUBY_VERSION}".freeze
	puts "Running sinatra version: #{Sinatra::VERSION}".freeze

  HNP = 'Host not permitted'.freeze
  CATALOG_RR = 'Catalog Request Received'.freeze
  UNABLE_TO_PROVISION_SI = 'Unable to provision service instance'.freeze
  SERVICE_INSTANCE_NF = 'Service Instance not found'.freeze
  UNBIND_REQUEST_R = 'Unbind Request Received'.freeze
  FAILDE_TO_F = "Failed to fetch notifications".freeze
  APPLICATION_J = 'application/json'.freeze

	use Rack::JSONBodyParser

  configure :production, :development, :test do
    enable :logging
    before do
      halt 403, HNP unless ENV['ALLOWED_HOST'].include?(request.host)
    end
  end

  use Rack::Auth::Basic do |username, password|
    username == ENV['SECURITY_USER_NAME'] && password == ENV['SECURITY_USER_PASSWORD']
  end

  get '/v2/catalog' do
	  content_type :json
	  logger.info CATALOG_RR
	  Catalog.instance.catalog.to_json
	end

	put '/v2/service_instances/:id' do |id|
		content_type :json
    plan_id = params[:plan_id]
    plan = Catalog.instance.find_plan(plan_id)
    logger.info "Provision Request Received: Plan: #{plan_id} - Service Instance ID: #{id}".freeze
    response = Teamserver.provision(id, plan.credentials)
    if response.code == 201 || ENV['CONTRAST_BACKWARDS_COMPAT']
    	status 201
      {}.to_json
    else
      status response.code
      {:description => UNABLE_TO_PROVISION_SI}.to_json
    end
  end

  delete '/v2/service_instances/:instance_id' do |instance_id|
    content_type :json
    plan_id = params[:plan_id]
    plan = Catalog.instance.find_plan(plan_id)
    logger.info "Unprovision Request Received: Plan: #{plan_id} - Service Instance ID: #{instance_id}".freeze
    Teamserver.unprovision(instance_id, plan.credentials)
    status 200
    {}.to_json
  end

  put '/v2/service_instances/:instance_id/service_bindings/:id' do |instance_id, binding_id|
  	content_type :json

  	plan_id = params[:plan_id]
  	logger.info "Bind Request Received - Plan: #{plan_id}".freeze
    plan = Catalog.instance.find_plan(plan_id)
    res = Teamserver.bind(instance_id, binding_id, plan.credentials)

    if plan
      status 200
      {:credentials => plan.credentials}.to_json
    else
      status 404
      {:msg => SERVICE_INSTANCE_NF}.to_json
    end
  end

  delete '/v2/service_instances/:instance_id/service_bindings/:id' do |instance_id, binding_id|
    content_type :json
    logger.info UNBIND_REQUEST_R
    status 200
    {}.to_json
  end

  get '/notifications/count' do
  	content_type :json
  	env_keys

  	api_url_to_uri(ENV['NOTIFICATIONS_COUNT_API'])
	  set_req_headers(@uri)
	  get_a_response_for_req(@req)

	  if @res.is_a?(Net::HTTPSuccess)
	    body = JSON.parse(@res.body)
	    { success: true, count: body["count"] }.to_json
	  else
	    status @res.code.to_i
	    { success: false, error: FAILDE_TO_F }.to_json
	  end
  end

  get '/notifications/expand' do
  	content_type :json
  	env_keys

	  api_url_to_uri(ENV['NOTIFICATIONS_EXPAND'])
	  set_req_headers(@uri)
	  get_a_response_for_req(@req)

	  if @res.is_a?(Net::HTTPSuccess)
	    body = JSON.parse(@res.body)
	    { success: true, data: body }.to_json
	  else
	    status @res.code.to_i
	    { success: false, error: FAILDE_TO_F }.to_json
	  end
  end

  put '/notifications/read' do
  	content_type :json
  	env_keys

  	api_url_to_uri(ENV['NOTIFICATIONS_READ'])
	  set_req_headers_put(@uri)
	  get_a_response_for_req(@req)

	  if @res.is_a?(Net::HTTPSuccess)
	    body = JSON.parse(@res.body)
	    { success: true, data: body }.to_json
	  else
	    status @res.code.to_i
	    { success: false, error: FAILDE_TO_F }.to_json
	  end
  end

  private

  def env_keys
    @auth_string = Base64.strict_encode64("#{ENV['CONTRAST_USERNAME']}:#{ENV['CONTRAST_SERVICE_KEY']}")
    @auth_string = "Basic #{@auth_string}".freeze
    @auth_string
  end

  def api_url_to_uri(api_url)
  	@uri = URI(api_url)
  end

  def set_req_headers(uri)
  	@req = Net::HTTP::Get.new(uri)
    process_headers(@req)
  end

  def set_req_headers_put(uri)
  	@req = Net::HTTP::Put.new(uri)
    process_headers(@req)
  end

  def get_a_response_for_req(req)
  	@res = Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: true) do |http|
	    http.request(@req)
	  end
  end

  def process_headers(req)
    @req = req
    @req['Authorization'] = @auth_string
    @req['API-Key'] = ENV['API_KEY']
    @req['Accept'] = APPLICATION_J
    @req
  end
end
