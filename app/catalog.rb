# frozen_string_literal: true

require 'yaml'
require 'json'
require 'singleton'

# Catalog of services
class Catalog
  include Singleton

  attr_reader :catalog

  def initialize
    load_catalog_config
    build_catalog
  end

  def load_catalog_config
    # Load catalog configuration from settings.yml file
    settings_path = File.join(Dir.pwd, 'app', 'config', 'settings.yml')

    raise "settings.yml file is missing at #{settings_path}" unless File.exist?(settings_path)

    @catalog = YAML.load_file(settings_path)['catalog']
  end

  def build_catalog
    validate_env!
    parse_env_plans!
    assign_plans_to_catalog!
  end

  def find_plan(plan_id)
    @plans.find { |plan| plan.id == plan_id }
  end

  private

  def validate_env!
    raise 'CONTRAST_SERVICE_PLANS environment variable is missing' unless ENV['CONTRAST_SERVICE_PLANS']
  end

  def parse_env_plans!
    env_plans = JSON.parse(ENV['CONTRAST_SERVICE_PLANS'])
    @plans = env_plans.map do |key, plan|
      Model::Plan.from_hash(plan)
    rescue StandardError => e
      raise "Error parsing plan #{key}: #{e.message}"
    end
  end

  def assign_plans_to_catalog!
    raise 'Catalog structure is invalid. Unable to find services key.' unless @catalog&.dig('services')&.first

    @catalog['services'].first['plans'] = @plans
  end
end
