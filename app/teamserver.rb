require 'httparty'
require 'base64'
require 'json'

class Teamserver
  BASE_PATH = '/ng/pivotal'.freeze

  # For Provisioning
  def self.provision service_instance_id, credential
    path = "/instances/#{service_instance_id}"
    url = build_url(credential.teamserver_url, path)
    options = { body: {organizationUuid: credential.org_uuid}.to_json, headers: build_headers(credential) }
    build_proxy(options, credential)
    HTTParty.post(url, options)
  end

  # For Binding
  def self.bind service_instance_id, binding_instance_id, credential
    path = "/instances/#{service_instance_id}/bindings/#{binding_instance_id}"
    url = build_url(credential.teamserver_url, path)
    options = { body: {organizationUuid: credential.org_uuid}.to_json, headers: build_headers(credential) }
    build_proxy(options, credential)
    HTTParty.post(url, options)
  end

  # For Deprovisioning
  def self.unprovision service_instance_id, credential
    path = "/instances/#{service_instance_id}"
    url = build_url(credential.teamserver_url, path)
    options = { headers: build_headers(credential) }
    build_proxy(options, credential)
    HTTParty.delete(url, options)
  end

  # teamserver url should be something like:
  # https://app.contrastsecurity.com
  # we then need to append /Contrast/api
  # then append path: which is /ng/pivotal/{already interpolated values}
  def self.build_url teamserver_url, path
    teamserver_url = teamserver_url[0...-1] if teamserver_url[-1] == '/' # if the provided teamserver url has / at the end remove it
    "#{teamserver_url}/Contrast/api#{BASE_PATH}#{path}"
  end

  def self.build_headers credential
    {
      'API-Key': credential.api_key,
      'Authorization': build_authorization(credential),
      'Content-Type': 'application/json',
    }
  end

  def self.build_proxy options, credential
    if !credential.proxy_host.to_s.empty?
      options.merge!({http_proxyaddr: credential.proxy_host, http_proxyport: credential.proxy_port})
    end

    if !credential.proxy_user.to_s.empty?
      options.merge!({http_proxyuser: credential.proxy_user, http_proxypass: credential.proxy_pass['secret']})
    end

    options
  end

  def self.build_authorization credential
    Base64.strict_encode64("#{credential.username}:#{credential.service_key}") # strict_encode64 doesn't put newlines every 60th char...
  end
end
