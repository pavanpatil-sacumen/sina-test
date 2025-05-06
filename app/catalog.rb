require 'yaml'
require 'json'
require 'singleton'

class Catalog
  include Singleton

  attr_reader :catalog

  def initialize
    @catalog = YAML.load_file(File.join(Dir.pwd,'app','config', 'settings.yml'))['catalog']
    build_catalog
  end

  def build_catalog
    env_plans = JSON.parse(ENV['CONTRAST_SERVICE_PLANS'])
    @plans = []
    env_plans.each do |key, plan|
      plan = Model::Plan.from_hash(plan)
      @plans << plan
    end
    @catalog['services'].first['plans'] = @plans
  end

  def find_plan plan_id
    @plans.find {|plan| plan.id == plan_id}
  end

  def catalog_response
    @catalog
  end
end
