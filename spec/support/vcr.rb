VCR.configure do |c|
  c.configure_rspec_metadata!
  c.cassette_library_dir     = 'spec/cassettes'
  c.hook_into                :faraday
  c.default_cassette_options = { :record => :new_episodes }
  c.filter_sensitive_data('<API_TOKEN>') { ENV['INSTAGRAM_API_TOKEN'] }
end
