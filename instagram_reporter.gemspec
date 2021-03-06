# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'instagram_reporter/version'

Gem::Specification.new do |spec|
  spec.name          = "instagram_reporter"
  spec.version       = InstagramReporter::VERSION
  spec.authors       = ["luki3k5" "mpikula"]
  spec.email         = ["luki3k5@gmail.com" "mariusz.pikula@gmail.com"]
  spec.description   = 'This gem allows to easily get data from Instagram'
  spec.summary       = 'This gem allows to easily get data from Instagram'
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_dependency "rails",   '>=3.2.12'
  spec.add_dependency "faraday", '0.9.1'
  spec.add_dependency "capybara"
  spec.add_dependency "nokogiri"
  spec.add_dependency "faraday_middleware"
  spec.add_dependency "oj"
  spec.add_dependency "typhoeus"
  spec.add_dependency "cane"
  spec.add_dependency "rubocop"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock", '1.8.0'
end
