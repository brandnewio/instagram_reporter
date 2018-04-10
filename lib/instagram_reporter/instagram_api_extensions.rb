module InstagramReporter
  module InstagramApiExtensions
    CHROME_WIN_UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36'

    def get_user_info_by_access_token(profile_name, access_token)
      fetch_and_process_data(:transform_user_info, profile_name)
    end

    def get_user_recent_media(_user_id, profile_name, max_tag_id = nil)
      fetch_and_process_data(:transform_user_recent_media, profile_name)
    end

    # TO CHANGE
    # https://www.instagram.com/web/search/topsearch/?context=blended&query=kuldeep&rank_token=0.11054731410424479
    def get_users_by_name(username, access_token = nil)
      {
        result: 'error'
      }
    end

    def call_api_by_access_token_for_media_file_stats(instagram_link, access_token)
      url = instagram_link + "?__a=1"
      resp = conn.get(url)
      if resp.status == 200
        raw_media_info = JSON.parse(resp.body)
        transform_media_info(raw_media_info)
      else
        {
          result: 'error',
          body: resp.body,
          status: resp.status,
          url: url
        }
      end.with_indifferent_access
    end

    private

      def fetch_and_process_data(sanitizer_method_name, profile_name)
        url = "https://www.instagram.com/#{profile_name}/?__a=1"
        resp = conn.get(url)
        if resp.status == 200
          raw_user_info = JSON.parse(resp.body)
          user_info = raw_user_info['graphql']['user']
          if user_info.nil?
            media_not_found_response(url)
          elsif user_info['is_private'].to_s == 'true'
            private_profile_response(url)
          else
            send(sanitizer_method_name, user_info, profile_name)
          end
        elsif resp.status == 404
          media_not_found_response(url)
        else
          media_error_response(url: url, status: resp.status, body: resp.body)
        end.with_indifferent_access
      end

      def transform_user_info(user_info, _)
        {
          data: {
            id: user_info['id'],
            username: user_info['username'],
            profile_picture: user_info['profile_pic_url'],
            full_name: user_info['full_name'],
            bio: user_info['biography'],
            counts: {
              media: user_info['edge_owner_to_timeline_media']['count'],
              followed_by: user_info['edge_followed_by']['count'],
              follows: user_info['edge_follow']['count']
            }
          },
          result: 'ok',
          meta: {
            code: 200
          }
        }
      end

      def transform_user_recent_media(user_info, profile_name)
        user_media = user_info['edge_owner_to_timeline_media'] || {}
        {
          # Because we can't use the next_max_tag_id endpoint, so setting it to +nil+
          # pagination: {
          #   next_max_tag_id: user_media['page_info']['end_cursor']
          # }.compact.presence,
          pagination: nil,
          result: 'ok',
          data: user_media['edges'].map do |edge|
            node = edge['node']
            images = [:thumbnail, :low_resolution, :standard_resolution].map.with_index do |k, i|
              source = node['thumbnail_resources'][i*2]
              [
                k,
                {
                  url: source['src'],
                  width: source['config_width'],
                  height: source['config_height']
                }
              ]
            end.to_h
            caption = node['edge_media_to_caption']['edges'].first.try(:[], 'node').try(:[], 'text')
            tags = extract_tags(caption)

            {
              id: node['id'],
              user: {
                id: node['owner']['id'],
                username: profile_name
              },
              images: images,
              tags: tags,
              created_time: node['taken_at_timestamp'],
              type: node['__typename'][5..-1].downcase,
              likes: {
                count: node['edge_media_preview_like']['count']
              },
              comments: {
                count: node['edge_media_to_comment']['count']
              },
              link: "https://instagram.com/p/#{node['shortcode']}",
              caption: { 
                text: caption
              }.compact.presence
            }
          end
        }
      end

      def transform_media_info(raw_media_info)
        media_info = raw_media_info['graphql']['shortcode_media']
        caption = media_info['edge_media_to_caption']['edges'].first.
                    try(:[], 'node').try(:[], 'text')

        {
          likes: {
            count: media_info['edge_media_preview_like']['count']
          },
          comments: {
            count: media_info['edge_media_to_comment']['count']
          },
          tags: extract_tags(caption),
          result: 'ok'
        }
      end

      def conn
        ssl_opt = if ENV['PROXY_CA_FILE_PATH'].present?
                    {ssl: {verify: true, ca_file: ENV['PROXY_CA_FILE_PATH']}}
                  else
                    {ssl: {verify: false}}
                  end
        Faraday.new(ssl_opt) do |faraday|
          faraday.request  :url_encoded
          # faraday.use      FaradayMiddleware::FollowRedirects
          faraday.adapter  :typhoeus
          faraday.proxy    roll_proxy_server
          faraday.options.timeout = (ENV['INSTAGRAM_REQUEST_TIMEOUT_LIMIT'] || 15).to_i
          faraday.headers['user-agent'] = CHROME_WIN_UA
        end
      end

      def roll_proxy_server
        # Algorithm for choosing proxy server, e.g. 
        # 
        # server = redis.lpop('proxy_servers')
        # redis.rpush('proxy_server', server)
        # server

        ENV['PROXY_SERVER'] #|| "http://ec2-52-16-66-173.eu-west-1.compute.amazonaws.com:9888"
      end

      def extract_tags(text)
        text.to_s.scan(/#[A-z\d-]+/).map{|x| x[1..-1] }
      end

      def media_error_response(url:, status:, body:)
        {
          result: 'error',
          body: "#{body} APINotAllowedError you cannot view this resource",
          status: status,
          url: url
        }
      end

      def private_profile_response(url)
        {
          result: 'error',
          status: 400,
          url: url,
          body: 'APINotAllowedError you cannot view this resource',
        }
      end

      def media_not_found_response(url)
        {
          result: 'error',
          status: 404,
          url: url,
          body: 'Page Not Found, APINotFoundError'
        }
      end
  end
end
