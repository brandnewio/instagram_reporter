# Temporary class
module InstagramReporter
  extend self

  class NilLogger
    def self.debug(description)
    end
  end

  def logger
    if defined?(IssuesLogger)
      IssuesLogger
    else
      NilLogger
    end
  end
end

