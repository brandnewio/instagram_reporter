require "instagram_reporter/version"
require 'rubygems'

# DEPENDENCIES
require 'faraday'
require 'faraday_middleware'
require 'json'
require 'capybara'
require 'capybara/dsl'
require 'nokogiri'
require 'oj'
require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'rubocop'
require 'active_support/core_ext/hash'

# MAIN FILES
require 'instagram_reporter/instagram_api_extensions'
require 'instagram_reporter/instagram_interactions_base'
require 'instagram_reporter/instagram_api_caller'
require 'instagram_reporter/instagram_website_caller'
require 'instagram_reporter/instagram_website_scraper'

module InstagramReporter
end
