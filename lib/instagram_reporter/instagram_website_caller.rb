# encoding: UTF-8

class InstagramWebsiteCaller < InstagramInteractionsBase
  attr_accessor :website_connection

  def initialize
    super
    @website_connection = Faraday.new(url: WEB_BASE_URL) do |faraday|
      faraday.request  :url_encoded
      faraday.use FaradayMiddleware::FollowRedirects
      faraday.adapter  Faraday.default_adapter
    end
  end

  def get_profile_page(account_name)
    @website_connection.get("/#{account_name}").body
  end

  def get_media_file_page(instagram_media_link)
    @website_connection.get("/p/#{instagram_media_link.split('/').last}").body
  end
end
