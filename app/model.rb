module Model
end

require_relative 'model/credential'
require_relative 'model/plan' # depends on models/credential, make sure loaded after
