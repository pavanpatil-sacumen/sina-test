# frozen_string_literal: true

module Model
  # Represents a subscription Credential
  class Credential
    attr_accessor :teamserver_url,
                  :org_uuid,
                  :api_key,
                  :service_key,
                  :username,
                  :proxy_user,
                  :proxy_pass,
                  :proxy_host,
                  :proxy_port

    # Initialize Credential object from hash
    def self.from_hash(hash)
      Model::Credential.new.tap { |cred| attrs_from_hash(cred, hash) }
    end

    ATTR_KEYS = %w[
      teamserver_url
      org_uuid
      api_key
      service_key
      username
      proxy_user
      proxy_pass
      proxy_host
    ].freeze

    def self.attrs_from_hash(cred, hash)
      assign_basic_attrs(cred, hash)
      assign_special_attrs(cred, hash)
    end

    def self.assign_basic_attrs(cred, hash)
      ATTR_KEYS.each { |key| cred.send("#{key}=", hash[key]) }
    end

    def self.assign_special_attrs(cred, hash)
      cred.proxy_port = hash['proxy_port']&.to_i
    end

    def as_json(*)
      attributes_to_json
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end

    private

    def attributes_to_json
      basic_attributes.merge(proxy_attributes)
    end

    def basic_attributes
      {
        teamserver_url: teamserver_url,
        org_uuid: org_uuid,
        api_key: api_key,
        service_key: service_key,
        username: username
      }
    end

    def proxy_attributes
      {
        proxy_user: proxy_user,
        proxy_pass: proxy_pass,
        proxy_host: proxy_host,
        proxy_port: proxy_port
      }
    end
  end
end
