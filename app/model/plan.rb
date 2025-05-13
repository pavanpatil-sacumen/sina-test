# frozen_string_literal: true

module Model
  # Represents a subscription plan
  class Plan
    DESCRIPTION = 'Connect Contrast to an application with this plan\'s credentials'
    attr_accessor :name, :id, :description, :metadata, :credentials

    def self.from_hash(hash)
      plan = Model::Plan.new
      plan.name = hash['name']
      plan.id = hash['org_uuid']
      plan.description = DESCRIPTION
      plan.metadata = build_meta(hash)
      plan.credentials = Model::Credential.from_hash(hash)
      plan
    end

    def self.build_meta(hash)
      {
        bullets: [
          "Contrast Org UUID: #{hash['org_uuid']}",
          "Contrast User: #{hash['username']}",
          "Teamserver URL: #{hash['teamserver_url']}"
        ]
      }
    end

    def as_json(*_args)
      {
        name: name,
        id: id,
        description: description,
        metadata: metadata
      }
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end
  end
end
