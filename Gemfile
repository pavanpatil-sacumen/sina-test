# frozen_string_literal: true

source 'https://rubygems.org'

# Use a Ruby version that is supported by both TAS 6.0 and TAS 10.0
ruby '3.2.5' # Matches the TAS buildpack supported Ruby version

# Core dependencies
gem 'dotenv', '~> 3.1' # Load env vars from .env files (Compatible with both)
gem 'httparty', '~> 0.21.0' # REST client for API calls (Compatible with both)
gem 'json', '~> 2.7' # Explicitly pinned for stability
gem 'rack', '~> 2.2.6' # Compatible with Sinatra 3.0+ (Both TAS 6.0 and 10.0)
gem 'rake', '~> 13.1' # Latest compatible version (Should be fine for both)
gem 'sinatra', '~> 3.0.6' # Stable version of Sinatra 3 (Compatible with both TAS versions)
gem 'sshkey', '~> 2.0' # Lightweight SSH key generation (Compatible with both TAS versions)

gem 'rack-contrib', '~> 2.3'   # Useful Rack middleware (e.g., JSONP) (Compatible with both)

gem 'puma', '~> 6.4'           # Recommended web server for Ruby apps (Compatible with both)
gem 'rackup'                   # A general server command for Rack applications.

# Test dependencies (both for TAS 6.0 and 10.0)
group :test do
  gem 'byebug', '~> 12.0' # Byebug is a Ruby debugger
  gem 'foreman', '~> 0.88.1' # Process manager for applications with multiple components
  gem 'minitest', '~> 5.20' # Simple and fast test library (Works with both TAS versions)
  gem 'mocha', '~> 2.1', require: false # Mock/stub library (Compatible with both)
  gem 'pry', '~> 0.14.2' # Powerful interactive REPL/debugger (Compatible with both)
  gem 'rack-test', '~> 2.1' # For simulating requests to Rack apps (Compatible with both)
  gem 'rspec', '~> 3.12' # Popular BDD-style test framework (Works with both TAS versions)
  gem 'simplecov', '~> 0.22.0' # Code coverage for Ruby
  gem 'webmock', '~> 3.19' # HTTP request stubbing (Compatible with both)
end

group :development, :test do
  gem 'rerun', '~> 0.14.0' # Restarts your app when a file changes
  gem 'rubocop', require: false # RuboCop is a Ruby code style checking and code formatting tool
end
