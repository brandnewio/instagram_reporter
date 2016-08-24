# encoding: UTF-8

class InstagramApiCaller < InstagramInteractionsBase

  EMOJI_AND_SKIN_TONES_REGEXP =
    /
    [\u{00A9}\u{00AE}\u{203C}\u{2049}\u{2122}\u{2139}\u{2194}-\u{2199}\u{21A9}-\u{21AA}
    \u{231A}-\u{231B}\u{2328}\u{23CF}\u{23E9}-\u{23F3}\u{23F8}-\u{23FA}\u{24C2}\u{25AA}-\u{25AB}
    \u{25B6}\u{25C0}\u{25FB}-\u{25FE}\u{2600}-\u{2604}\u{260E}\u{2611}\u{2614}-\u{2615}\u{2618}
    \u{261D}\u{2620}\u{2622}-\u{2623}\u{2626}\u{262A}\u{262E}-\u{262F}\u{2638}-\u{263A}
    \u{2648}-\u{2653}\u{2660}\u{2663}\u{2665}-\u{2666}\u{2668}\u{267B}\u{267F}\u{2692}-\u{2694}
    \u{2696}-\u{2697}\u{2699}\u{269B}-\u{269C}\u{26A0}-\u{26A1}\u{26AA}-\u{26AB}\u{26B0}-\u{26B1}
    \u{26BD}-\u{26BE}\u{26C4}-\u{26C5}\u{26C8}\u{26CE}-\u{26CF}\u{26D1}\u{26D3}-\u{26D4}
    \u{26E9}-\u{26EA}\u{26F0}-\u{26F5}\u{26F7}-\u{26FA}\u{26FD}\u{2702}\u{2705}\u{2708}-\u{270D}
    \u{270F}\u{2712}\u{2714}\u{2716}\u{271D}\u{2721}\u{2728}\u{2733}-\u{2734}\u{2744}\u{2747}
    \u{274C}\u{274E}\u{2753}-\u{2755}\u{2757}\u{2763}-\u{2764}\u{2795}-\u{2797}\u{27A1}\u{27B0}
    \u{27BF}\u{2934}-\u{2935}\u{2B05}-\u{2B07}\u{2B1B}-\u{2B1C}\u{2B50}\u{2B55}\u{3030}\u{303D}
    \u{3297}\u{3299}\u{1F004}\u{1F0CF}\u{1F170}-\u{1F171}\u{1F17E}-\u{1F17F}\u{1F18E}
    \u{1F191}-\u{1F19A}\u{1F201}-\u{1F202}\u{1F21A}\u{1F22F}\u{1F232}-\u{1F23A}
    \u{1F250}-\u{1F251}\u{1F300}-\u{1F321}\u{1F324}-\u{1F393}\u{1F396}-\u{1F397}
    \u{1F399}-\u{1F39B}\u{1F39E}-\u{1F3F0}\u{1F3F3}-\u{1F3F5}\u{1F3F7}-\u{1F4FD}
    \u{1F4FF}-\u{1F53D}\u{1F549}-\u{1F54E}\u{1F550}-\u{1F567}\u{1F56F}-\u{1F570}
    \u{1F573}-\u{1F579}\u{1F587}\u{1F58A}-\u{1F58D}\u{1F590}\u{1F595}-\u{1F596}\u{1F5A5}\u{1F5A8}
    \u{1F5B1}-\u{1F5B2}\u{1F5BC}\u{1F5C2}-\u{1F5C4}\u{1F5D1}-\u{1F5D3}\u{1F5DC}-\u{1F5DE}
    \u{1F5E1}\u{1F5E3}\u{1F5EF}\u{1F5F3}\u{1F5FA}-\u{1F64F}\u{1F680}-\u{1F6C5}\u{1F6CB}-\u{1F6D0}
    \u{1F6E0}-\u{1F6E5}\u{1F6E9}\u{1F6EB}-\u{1F6EC}\u{1F6F0}\u{1F6F3}\u{1F910}-\u{1F918}
    \u{1F980}-\u{1F984}\u{1F9C0}]|\\u{1F3FB}|\\u{1F3FC}|\\u{1F3FD}|\\u{1F3FF}
    /x


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

  def get_similar_hashtags_by_access_token(tag, access_token)
    params = query_params(access_token)
    api_get_and_parse("/v1/tags/search?q=#{tag}", params)
  end

  def get_similar_hashtags_by_api_token(tag)
    params = query_params(nil)
    api_get_and_parse("/v1/tags/search?q=#{tag}", params)
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

  def get_media_likes_by_access_token(media_id, access_token)
    params = query_params(access_token)
    api_get_and_parse("/v1/media/#{media_id}/likes", params)
  end

  def get_media_comments_by_access_token(media_id, access_token)
    params = query_params(access_token)
    api_get_and_parse("/v1/media/#{media_id}/comments", params)
  end

  def get_users_by_name(username, access_token = nil)
    params = query_params(access_token).merge!(q: username)
    puts "params: #{params}"
    api_get_and_parse("/v1/users/search", params, true)
  end

  def call_api_by_access_token_for_media_file_location(instagram_media_id, access_token)
    call_api_by_access_token_for_media_info(instagram_media_id, access_token, 'location')
  end

  def get_location_info_by_access_token(longitude, latitude, access_token)
    params = query_params(access_token).merge!(lng: longitude, lat: latitude)
    api_get_and_parse("/v1/locations/search", params, true)
  end

  def call_api_by_access_token_for_media_file_stats(instagram_media_id, access_token)
    call_api_by_access_token_for_media_info(instagram_media_id, access_token, ['likes', 'comments', 'tags'])
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
        data = clear_data(data)
        Oj.load(data)['data']
      rescue Oj::ParseError
        raise "Oj Parser Error: unable to parse instagram api response data #{data}"
      end
    end

    def clear_data(data)
      # Remove extra `\ud83d` code because each emoji starts with `\ud83d` and
      # then comes with it's own code, like: \ud83d\ude21 for 😡
      # but sometimes instagram is sending incorrect code, i.e. sending 2
      # `\\ud83d` code without original emoiji code.
      data = data.gsub(/\\ud83d\\ud83d/i, '\\ud83d')
      data = data.gsub(/\\ud83d([^\\])/i, "\\1").gsub(EMOJI_AND_SKIN_TONES_REGEXP, "")
      # Escape special form of multibyte UTF in format \u{}
      data.gsub(/\\u{(\w+)}/, '\u\1')
    end

    def get_pagination(data)
      Oj.load(data)['pagination']
    end

    def api_get_and_parse(uri, params, get_pagination = false)

      response = Hash.new
      api_response = api_connection.get(uri, params) do |req|
        req.options = DEFAULT_REQUEST_OPTIONS
      end
       puts "#{params} #{uri} #{api_response.inspect}"
      if(api_response.status == 200)
        response['data']       = parse_response(api_response, uri, params)
        response['pagination'] = get_pagination(api_response.body) if get_pagination
        response['result']     = 'ok'
        response['status']     = api_response.status
      else
        response = parse_response(api_response, uri, params)
      end

      return response

    end

    def parse_response(response, uri, params)
      case response.status
      when 200
        parse_json(response.body)
      when 400, 404, 500, 502, 503, 504
        {
          result: 'error',
          body: response.body,
          status: response.status,
          url: uri
        }
      else
        raise "unsupported response status during GET #{uri}: #{response.status}. Request params #{params}. response body : #{response.body}"
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
        raise "call for media #{actions} (media_id: #{instagram_media_id}) failed with response #{@response.inspect}"
      end
    end

    def call_api_by_api_token_for_media_file(media_id, action)
      @uri="/v1/media/#{media_id}?client_id=#{API_TOKEN}"
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
        raise "call for media #{action} (media_id: #{media_id}) failed with response #{@response.inspect}"
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
      { result: 'error', body: response_body }
    end
end
