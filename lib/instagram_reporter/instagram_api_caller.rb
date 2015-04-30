# encoding: UTF-8

class InstagramApiCaller < InstagramInteractionsBase

  def get_instagram_accounts_by_api_token
    api_get_and_parse(POPULAR_INSTAGRAM_MEDIA_URL, query_params(nil))
  end

  def get_instagram_accounts_by_access_token(access_token)
    api_get_and_parse(POPULAR_INSTAGRAM_MEDIA_URL, query_params(access_token))
  end

  def get_hashtag_info_by_access_token(tag, access_token, max_tag_id = nil)
    params = query_params(access_token)
    params.merge!(max_tag_id: max_tag_id) unless max_tag_id.nil?
    api_get_and_parse("/v1/tags/#{tag}/media/recent", params, true)
  end

  def get_hashtag_info_by_api_token(tag, max_tag_id = nil)
    params = query_params(nil)
    params.merge!(max_tag_id: max_tag_id) unless max_tag_id.nil?
    api_get_and_parse("/v1/tags/#{tag}/media/recent", params, true)
  end

  def get_hashtag_media_count_by_access_token(tag, access_token)
    params = query_params(access_token)
    api_get_and_parse("/v1/tags/#{tag}", params)
  end

  def get_hashtag_media_count_by_api_token(tag)
    params = query_params(nil)
    api_get_and_parse("/v1/tags/#{tag}", params)
  end

  def get_user_info_by_api_token(user_id)
    params = query_params(nil)
    api_get_and_parse("/v1/users/#{user_id}", params)
  end

  def get_user_info_by_access_token(user_id, access_token)
    params = query_params(access_token)
    api_get_and_parse("/v1/users/#{user_id}", params)
  end

  def get_user_recent_media(user_id, access_token, max_tag_id = nil)
    params = query_params(access_token)
    params.merge!(max_tag_id: max_tag_id) unless max_tag_id.nil?
    api_get_and_parse("/v1/users/#{user_id}/media/recent", params, true)
  end

  def get_users_by_name(username, access_token = nil)
    params = query_params(access_token).merge!(q: username)
    api_get_and_parse("/v1/users/search", params, true)
  end

  def call_api_by_access_token_for_media_file_location(instagram_media_id, access_token)
    call_api_by_access_token_for_media_info(instagram_media_id, access_token, 'location')
  end

  def get_location_info_by_access_token(longitude, latitude, access_token)
    params = query_params(access_token).merge!(lng: longitude, lat: latitude)
    api_get_and_parse("/v1/locations/search", params, true)
  end

  def call_api_by_access_token_for_media_file_comments(instagram_media_id, access_token)
    call_api_by_access_token_for_media_info(instagram_media_id, access_token, 'comments')
  end

  def call_api_by_access_token_for_media_file_likes(instagram_media_id, access_token)
    call_api_by_access_token_for_media_info(instagram_media_id, access_token, 'likes')
  end

  def call_api_by_access_token_for_media_file_likes_and_comments(instagram_media_id, access_token)
    call_api_by_access_token_for_media_info(instagram_media_id, access_token, ['likes', 'comments'])
  end

  def call_api_by_access_token_for_media_file_stats(instagram_media_id, access_token)
    call_api_by_access_token_for_media_info(instagram_media_id, access_token, ['likes', 'comments', 'tags'])
  end

  def call_api_by_api_token_for_media_file_comments(instagram_media_id)
    call_api_by_api_token_for_media_file(instagram_media_id, 'comments')
  end

  def call_api_by_api_token_for_media_file_likes(instagram_media_id)
    call_api_by_api_token_for_media_file(instagram_media_id, 'likes')
  end

  def call_api_by_api_token_for_media_file_caption(instagram_media_id)
    call_api_by_api_token_for_media_file(instagram_media_id, 'caption')
  end

  def get_location(location_id, access_token)
    #https://api.instagram.com/v1/locations/1?access_token=ACCESS-TOKEN
    api_get_and_parse("/v1/locations/#{location_id}", query_params(access_token), false)
  end

  def get_followers(user_id, access_token, cursor = nil)
    #/v1/users/3/followed-by?access_token=ACCESS-TOKEN
    #/v1/users/45364550/followed-by
    params = query_params(access_token)
    params.merge!(cursor: cursor) unless cursor.nil?
    api_get_and_parse("/v1/users/#{user_id}/followed-by", params, true)
  end

  private

    def parse_json(data)
      begin
        Oj.load(data)['data']
      rescue Oj::ParseError
        raise "Oj Parser Error: unable to parse instagram api response data #{data}"
      end
    end

    def get_pagination(data)
      Oj.load(data)['pagination']
    end

    def api_get_and_parse(uri, params, get_pagination = false)
      response = Hash.new
      api_response = api_connection.get(uri, params) do |req|
        req.options = DEFAULT_REQUEST_OPTIONS
      end

      if(api_response.status == 200)
        response['data']       = parse_response(api_response, uri)
        response['pagination'] = get_pagination(api_response.body) if get_pagination
        response['result']     = 'ok'
        response['status']     = api_response.status
      else
        response = parse_response(api_response, uri)
      end

      return response

    end

    def parse_response(response, uri)
      case response.status
      when 200
        parse_json(response.body)
      when 400, 404, 500, 502, 503, 504
        InstagramReporter.logger.debug("Wrong response status during GET #{uri}: #{response.status}. Response body: #{response.body}")
        {
          result: 'error',
          body: response.body,
          status: response.status,
          url: uri
        }
      else
        raise "unsupported response status during GET #{uri}: #{response.status}. response body : #{response.body}"
      end
    end

    def query_params(access_token)
      access_token ? { access_token: access_token } : { client_id: API_TOKEN }
    end

    def call_api_by_access_token_for_media_info(instagram_media_id, access_token, actions)
      @uri = "/v1/media/#{instagram_media_id}?access_token=#{access_token}"
      get_response(@uri)

      case @response.status
      when 200
        resp_json = parse_json(@response.body)
        @response = { result: 'ok' }
        if actions.is_a?(Array)
          actions.each do |action|
            @response[action] = resp_json[action]
          end
        else
          return {result: 'error', body: 'no location value present'} if actions == 'location' && resp_json[actions].nil?
          @response = @response.merge(resp_json[actions])
        end
        @response
      when 400, 404, 500, 502, 503, 504
        set_response_body
      else
        raise "call for media #{actions} (media_id: #{instagram_media_id}) failed with response #{response.inspect}"
      end
    end

    def call_api_by_api_token_for_media_file(media_id, action)
      get_response("/v1/media/#{media_id}?client_id=#{API_TOKEN}")

      case @response.status
      when 200
        resp_json = parse_json(@response.body)
        if action == 'caption' && resp_json[action].nil?
          return {result: 'ok', text: nil}
        end
        return {result: 'ok'}.merge(resp_json[action])
      when 400, 404, 500, 502, 503, 504
        set_response_body
      else
        raise "call for media #{action} (media_id: #{media_id}) failed with response #{response.inspect}"
      end
    end

    def get_response(uri)
      @response ||= api_connection.get do |req|
        req.url uri
        req.options = DEFAULT_REQUEST_OPTIONS
      end
    end

    def api_connection
      @api_connection ||= Faraday.new(url: API_BASE_URL) do |faraday|
        faraday.request  :url_encoded
        faraday.use FaradayMiddleware::FollowRedirects
        faraday.adapter  :typhoeus
        faraday.options.timeout = 5
      end
    end

    def set_response_body
      response_body = ''
      begin
        response_body = Oj.load(@response.body)
      rescue Oj::ParseError
        response_body = @response.body
      end
      InstagramReporter.logger.debug("Wrong response status during GET #{@uri}: #{@response.status}. Response body: #{response_body}")
      { result: 'error', body: response_body }
    end
end
