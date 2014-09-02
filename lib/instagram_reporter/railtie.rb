require 'instagram-reporter'
require 'rails'

module InstagramReporter
  class Railtie < Rails::Railtie
    railtie_name :instagram_reporter

    rake_tasks do
      load "tasks/instagram-reporter.rake"
    end
  end
end
