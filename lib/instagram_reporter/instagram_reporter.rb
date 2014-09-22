# Temporary class
module InstagramReporter
  attr_accessor :logger
  extend self

  class NilLogger
    def self.debug(description)
    end
  end

  def logger
    @logger || NilLogger
  end
end

