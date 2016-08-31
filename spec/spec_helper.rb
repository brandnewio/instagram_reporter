# encoding UTF-8

require 'rubygems'
require 'rspec'
require 'vcr'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['INSTAGRAM_API_TOKEN'] = 'TEST-TOKEN-NOT-RELEVANT' unless ENV['INSTAGRAM_API_TOKEN']

require 'instagram_reporter'

RSpec.configure do |c|
  c.order = "random"
  c.tty = true
  c.color = true
end

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.cassette_library_dir     = 'spec/cassettes'
  c.hook_into                :typhoeus
  c.default_cassette_options = { :record => :new_episodes }
  c.filter_sensitive_data('<API_TOKEN>') { ENV['INSTAGRAM_API_TOKEN'] }
end

def puts(*args); end unless ENV['VERBOSE']
