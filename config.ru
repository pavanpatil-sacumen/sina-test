lib = File.expand_path('../app', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'sb_app'
run SBApp.new
