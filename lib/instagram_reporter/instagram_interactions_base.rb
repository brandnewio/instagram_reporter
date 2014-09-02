class InstagramInteractionsBase
  attr_accessor :mongoid_config

  API_BASE_URL                = 'https://api.instagram.com'
  WEB_BASE_URL                = 'http://instagram.com'
  API_TOKEN                   = ENV['INSTAGRAM_API_TOKEN']
  POPULAR_INSTAGRAM_MEDIA_URL = '/v1/media/popular'
  DEFAULT_REQUEST_OPTIONS     = {timeout: 15, open_timeout: 15}

  def initialize
    check_env_variables
  end

  private
  def check_env_variables 
      raise ArgumentError, "INSTAGRAM_API_TOKEN environment variable not set" unless API_TOKEN
  end
end
