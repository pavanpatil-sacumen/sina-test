module Model
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

    def self.from_hash hash
      credential = Model::Credential.new
      credential.teamserver_url = hash['teamserver_url']
      credential.org_uuid       = hash['org_uuid']
      credential.api_key        = hash['api_key']
      credential.service_key    = hash['service_key']
      credential.username       = hash['username']
      credential.proxy_user     = hash['proxy_user']
      credential.proxy_pass     = hash['proxy_pass']
      credential.proxy_host     = hash['proxy_host']
      credential.proxy_port     = hash['proxy_port']
      credential
    end

    # if you update these be careful - they have to match up to the keys that the Java Buildpack expects
    # https://github.com/cloudfoundry/java-buildpack/blob/master/lib/java_buildpack/framework/contrast_security_agent.rb#L58
    def as_json(*args)
      {
        teamserver_url: teamserver_url,
        org_uuid: org_uuid,
        api_key: api_key,
        service_key: service_key,
        username: username
      }
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end
  end
end
