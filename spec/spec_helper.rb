# encoding UTF-8

require 'rubygems'
require 'rspec'
require 'vcr'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['INSTAGRAM_API_TOKEN'] = 'TEST-TOKEN-NOT-RELEVANT' unless ENV['INSTAGRAM_API_TOKEN']

require 'instagram_reporter'
Dir[File.join(File.expand_path('../support/**/*.rb', __FILE__))].each {|f| require f}

RSpec.configure do |c|
  c.order = "random"
end

def puts(*args); end unless ENV['VERBOSE']
