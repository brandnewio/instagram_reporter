module InstagramReporter
  module InstagramApiExtensions

    # TO CHANGE
    def get_user_info_by_access_token(profile_name, access_token)
      url = "https://www.instagram.com/#{profile_name}/?__a=1"
      resp = conn.get(url)
      if resp.status == 200
        raw_user_info = JSON.parse(resp.body)
        if raw_user_info['is_private'] == 'true'
          {
            result: 'error',
            body: 'APINotAllowedError you cannot view this resource',
            status: 400,
            url: url
          }
        else
          transform_user_info(raw_user_info)
        end
      else
        {
          result: 'error',
          body: resp.body,
          status: resp.status,
          url: url
        }
      end.with_indifferent_access
    end

    # TO CHANGE
    def get_user_recent_media(user_id, profile_name, max_tag_id = nil)
      url = "https://instagram.com/graphql/query/"
      query_params = {
        query_id: ENV['INSTAGRAM_USER_QUERY_ID'] || "17888483320059182",
        id: user_id,
        first: 12,
        after: max_tag_id
      }.compact
      resp = conn.get(url, query_params)
      if resp.status == 200
        raw_user_media = JSON.parse(resp.body)
        transform_user_recent_media(raw_user_media, profile_name)
      else
        {
          result: 'error',
          body: response.body,
          status: response.status,
          url: uri
        }
      end.with_indifferent_access
    end

    # TO CHANGE
    # https://www.instagram.com/web/search/topsearch/?context=blended&query=kuldeep&rank_token=0.11054731410424479
    def get_users_by_name(username, access_token = nil)
      {
        result: 'error'
      }
    end

    # TO CHANGE
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

      def transform_user_info(raw_user_info)
        user_info = raw_user_info['graphql']['user']
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
          meta: {
            code: 200
          }
        }
      end

      def transform_user_recent_media(raw_user_media, profile_name)
        user_media = raw_user_media['data']['user']['edge_owner_to_timeline_media']

        {
          pagination: {
            next_max_id: user_media['page_info']['end_cursor']
          },
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
              type: node['__typename'][4..-1].downcase,
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
        @conn ||= Faraday.new do |faraday|
          faraday.request  :url_encoded
          faraday.use      FaradayMiddleware::FollowRedirects
          faraday.adapter  :typhoeus
          faraday.options.timeout = 5
        end
      end

      def extract_tags(text)
        text.to_s.scan(/#[A-z\d-]+/).map{|x| x[1..-1] }
      end
  end
end