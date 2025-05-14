# frozen_string_literal: true

require 'httparty'
require 'base64'
require 'json'
require 'logger'

# AjeAgent reports to Teamserver
class Teamserver
  BASE_PATH = ENV.fetch('TEAMSERVER_BASE_PATH', '/ng/pivotal')
  MAX_RETRIES = 3
  RETRY_BACKOFF = 2 # seconds
  DEFAULT_TIMEOUT = 10 # seconds
  LOGGER = Logger.new($stdout)

  def self.provision(service_instance_id, credential)
    post_instance("/instances/#{service_instance_id}", credential)
  end

  def self.bind(service_instance_id, binding_instance_id, credential)
    post_instance("/instances/#{service_instance_id}/bindings/#{binding_instance_id}", credential)
  end

  def self.unprovision(service_instance_id, credential)
    path = "/instances/#{service_instance_id}"
    url = build_url(credential.teamserver_url, path)
    options = build_options(credential)
    execute_with_retry(:delete, url, options)
  end

  def self.post_instance(path, credential)
    url = build_url(credential.teamserver_url, path)
    options = build_options(credential).merge(
      body: { organizationUuid: credential.org_uuid }.to_json
    )
    execute_with_retry(:post, url, options)
  end

  def self.execute_with_retry(method, url, options)
    retries = 0

    begin
      response = perform_request(method, url, options)
      raise_if_server_error(response)
      handle_response(response)
    rescue StandardError => e
      retry_or_raise(e, retries) { retries += 1 }
      retry
    end
  end

  def self.retry_or_raise(error, retries)
    if retries < MAX_RETRIES
      handle_retry(error, retries)
      yield
    else
      LOGGER.error("Request failed after #{MAX_RETRIES} attempts.")
      raise StandardError, "Teamserver request failed: #{error.message}"
    end
  end

  def self.perform_request(method, url, options)
    log_request(method, url, options)
    response = HTTParty.send(method, url, options)
    log_response(response)
    response
  end

  def self.raise_if_server_error(response)
    raise StandardError, "Server error: #{response.code} - #{response.body}" if response.code >= 500
  end

  def self.handle_retry(error, attempt)
    sleep_time = RETRY_BACKOFF**attempt
    LOGGER.warn("Retry #{attempt + 1}/#{MAX_RETRIES}: #{error.class} - #{error.message}. Sleeping #{sleep_time}s...")
    sleep(sleep_time)
  end

  def self.build_url(teamserver_url, path)
    teamserver_url = teamserver_url.chomp('/')
    "#{teamserver_url}/Contrast/api#{BASE_PATH}#{path}"
  end

  def self.build_headers(credential)
    {
      'API-Key' => credential.api_key,
      'Authorization' => build_authorization(credential).to_s,
      'Content-Type' => 'application/json',
      'User-Agent' => 'ContrastServiceBroker/1.0'
    }
  end

  def self.build_proxy(credential)
    proxy = {}
    if credential.proxy_host.to_s != ''
      proxy[:http_proxyaddr] = credential.proxy_host
      proxy[:http_proxyport] = credential.proxy_port
    end

    if credential.proxy_user.to_s != ''
      proxy[:http_proxyuser] = credential.proxy_user
      proxy[:http_proxypass] = credential.proxy_pass
    end

    proxy
  end

  def self.build_options(credential)
    {
      headers: build_headers(credential),
      timeout: DEFAULT_TIMEOUT
    }.merge(build_proxy(credential))
  end

  def self.build_authorization(credential)
    Base64.strict_encode64("#{credential.username}:#{credential.service_key}")
  end

  def self.handle_response(response)
    raise StandardError, "HTTP #{response.code}: #{response.body}" unless response.success?

    response
  end

  def self.log_request(method, url, options)
    LOGGER.info("Teamserver #{method.to_s.upcase} Request to #{url}")
    LOGGER.debug("Headers: #{options[:headers]}")
    LOGGER.debug("Body: #{options[:body]}") if options[:body]
  end

  def self.log_response(response)
    LOGGER.info("Teamserver Response: HTTP #{response.code}")
    LOGGER.debug("Response body: #{response.body}")
  end
end
