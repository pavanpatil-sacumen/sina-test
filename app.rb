require 'sinatra'

get '/frank-says' do
	'Hi, I am from sinatra now... hello!'
end

get '/hello/:name' do
  # matches "GET /hello/foo" and "GET /hello/bar"
  # params['name'] is 'foo' or 'bar'
  "Hello #{params['name']}!"
end

get '/wellcome/*/at/*' do
  # matches /wellcome/name/at/location
  # params['splat'] # => ["pavan", "bangalore"]
  "Wellcome #{params['splat'].first} at #{params['splat'].last}!"
end
