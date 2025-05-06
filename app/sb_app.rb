require 'sinatra'
require 'dotenv/load'
require 'byebug'
require 'json'
require 'yaml'

require_relative 'model'
require_relative 'catalog'

require 'rack'
require 'rack/contrib'

get '/v2/catalog' do
  content_type :json
  logger.info 'Catalog Request Received'
  Catalog.instance.catalog.to_json
end
