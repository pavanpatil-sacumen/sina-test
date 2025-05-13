# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'yaml'
require 'rack'
require 'rack/contrib'
require 'dotenv/load'
require 'pry'
require 'byebug'
require 'net/http'
require 'uri'
require 'base64'

# Models
require 'model'

# Services
require 'catalog'
require 'teamserver'

# API Gateways
class ServiceBrokerApp < Sinatra::Base
  # Rack middleware configuration
  use Rack::JSONBodyParser

  configure :production, :development do
    enable :logging
  end

  # Basic Authentication
  use Rack::Auth::Basic, 'Protected Area' do |username, password|
    Rack::Utils.secure_compare(username.to_s, ENV['SECURITY_USER_NAME'].to_s) &&
      Rack::Utils.secure_compare(password.to_s, ENV['SECURITY_USER_PASSWORD'].to_s)
  end

  before do
    # Adjust logging for both TAS versions
    logger.info "Request: #{request.request_method} #{request.path}"
    logger.debug "Params: #{params.inspect}"
  end

  # CATALOG
  get '/v2/catalog' do
    content_type :json
    logger.info 'Catalog Request Received'
    begin
      Catalog.instance.catalog.to_json
    rescue StandardError => e
      logger.error "Catalog Error: #{e.message}"
      status 500
      { description: 'Failed to fetch catalog' }.to_json
    end
  end

  # PROVISION
  put '/v2/service_instances/:id' do |id|
    content_type :json
    plan_id = params[:plan_id]

    plan = Catalog.instance.find_plan(plan_id)
    unless plan
      logger.warn "Plan not found: #{plan_id}"
      status 400
      return { description: 'Invalid plan_id' }.to_json
    end

    logger.info "Provision Request Received: Plan: #{plan_id} - Service Instance ID: #{id}"
    begin
      response = Teamserver.provision(id, plan.credentials)

      if response.code == 201 || ENV['CONTRAST_BACKWARDS_COMPAT']
        status 201
        {
          dashboard_url: "https://teamserver.example.com/dashboard/#{id}"
        }.to_json
      else
        status response.code
        { description: 'Unable to provision service instance' }.to_json
      end
    rescue StandardError => e
      logger.error "Provision Error: #{e.message}"
      status 500
      { description: 'Provisioning failed due to an internal error' }.to_json
    end
  end

  # LAST OPERATION
  get '/v2/service_instances/:instance_id/last_operation' do |instance_id|
    content_type :json
    logger.info "Last Operation Request Received for instance #{instance_id}"
    begin
      status 200
      { state: 'succeeded' }.to_json
    rescue StandardError => e
      logger.error "Last Operation Error: #{e.message}"
      status 500
      { description: 'Failed to fetch last operation status' }.to_json
    end
  end

  # UNPROVISION
  delete '/v2/service_instances/:instance_id' do |instance_id|
    content_type :json
    plan_id = params[:plan_id]

    plan = Catalog.instance.find_plan(plan_id)
    unless plan
      logger.warn "Plan not found: #{plan_id}"
      status 400
      return { description: 'Invalid plan_id' }.to_json
    end

    logger.info "Unprovision Request Received: Plan: #{plan_id} - Service Instance ID: #{instance_id}"
    begin
      Teamserver.unprovision(instance_id, plan.credentials)
      status 200
      {}.to_json
    rescue StandardError => e
      logger.error "Unprovision Error: #{e.message}"
      status 500
      { description: 'Unprovisioning failed due to an internal error' }.to_json
    end
  end

  # BIND
  put '/v2/service_instances/:instance_id/service_bindings/:id' do |instance_id, binding_id|
    content_type :json
    plan_id = params[:plan_id]

    logger.info "Bind Request Received - Plan: #{plan_id}, Instance: #{instance_id}, Binding: #{binding_id}"
    plan = Catalog.instance.find_plan(plan_id)
    unless plan
      logger.warn "Plan not found: #{plan_id}"
      status 400
      return { description: 'Invalid plan_id' }.to_json
    end

    begin
      Teamserver.bind(instance_id, binding_id, plan.credentials)
      status 200
      { credentials: plan.credentials }.to_json
    rescue StandardError => e
      logger.error "Bind Error: #{e.message}"
      status 500
      { description: 'Binding failed due to an internal error' }.to_json
    end
  end

  # UNBIND
  delete '/v2/service_instances/:instance_id/service_bindings/:id' do |instance_id, binding_id|
    content_type :json
    logger.info "Unbind Request Received for instance #{instance_id}, binding #{binding_id}"
    begin
      Teamserver.unbind(instance_id, binding_id)
      status 200
      {}.to_json
    rescue StandardError => e
      logger.error "Unbind Error: #{e.message}"
      status 500
      { description: 'Unbinding failed due to an internal error' }.to_json
    end
  end
end
