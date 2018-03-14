class InstagramWebsiteScraper

  SEARCHABLE_KEYWORDS = %w(contact business Business Facebook facebook fb email Twitter twitter Contact FB tumblr Blog blog mail http www)
  EMAIL_PATTERN_MATCH = /([^@\s*]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})/i
  PROFILE_STATS_REGEXP = /window\._sharedData\ \=(?<data>.*);/

  def contact_data_email(data)
    matched = data.match(EMAIL_PATTERN_MATCH)
    return matched.to_s if !matched.nil?
    nil
  end

  def find_other_contact_means(data)
    return data.gsub(',', '') if !data.match(EMAIL_PATTERN_MATCH).nil?

    SEARCHABLE_KEYWORDS.each do |ci|
      return data.gsub(',', '') if data.include?(ci)
    end
    nil
  end

# {
#  "username"=>"luki3k5”,
#  "bio"=>”",
#  "website"=>”",
#  "profile_picture"=>"https://instagramimages-a.akamaihd.net/profiles/profile_4907942_75sq_1392804574.jpg”,
#  "full_name"=>”",
#  "counts"=>{"media"=>37, "followed_by"=>34, "follows"=>3},
#  "id"=>"4907942”,
#  "isVerified"=>false,
#  "contact_data_email"=>nil,
#  "other_contact_means"=>nil
#  }
  def scrape_data_for_profile_page(html)
    returnee = nil
    el = Hash.new
    doc = Nokogiri::HTML(html)
    prematched_content = doc.content.match(/{"ProfilePage":.*}\]}/).to_s
    profile_data = JSON.parse(prematched_content)['ProfilePage'][0]['graphql']

    el['counts'] = {
      'followed_by' => profile_data['user']['edge_followed_by']['count'],
      'media'       => profile_data['user']['edge_owner_to_timeline_media']['count'],
      'follows'     => profile_data['user']['edge_follow']['count']
    }
    el['username'] = profile_data['user']['username']
    el['full_name'] = profile_data['user']['full_name'].to_s
    el['isVerified'] = profile_data['user']['is_verified']
    el['id'] = profile_data['user']['id']
    el['profile_picture'] = profile_data['user']['profile_pic_url']
    el['contact_data_email']  = contact_data_email(profile_data['user']['biography'].to_s)
    el['other_contact_means'] = find_other_contact_means(profile_data['user']['biography'].to_s)
    el['website'] = profile_data['user']['external_url'].to_s
    el['bio'] = profile_data['user']['biography'].to_s
    el
  end

  def get_likes_and_comments(html)
    returnee         = { status: 'online' }
    doc              = Nokogiri::HTML(html)

    if !doc.content.match(/Page Not Found/).nil?
      returnee.merge!({ status: 'offline', result: 'error', body: 'Page not found for media file' })
    else
      likes_content    = doc.content.scan(/"edge_media_preview_like":\{"count":([0-9]+)/)
      comments_content = doc.content.scan(/"edge_media_to_comment":\{"count":([0-9]+)/)

      if likes_content.nil? || comments_content.nil?
        { result: 'error', status: 'offline', body: 'could not scrape web page for likes and comments' }
      else
        likes = (likes_content.first.first || 0).to_s
        comments = (comments_content.first.first || 0).to_s
        returnee.merge!({ result: 'ok', likes_count: likes, comments_count: comments.size.to_s })
      end
    end
  end

  def get_profile_statistic(html)
    el = Hash.new

    doc = Nokogiri::HTML(html)
    prematched_content = doc.content.match(PROFILE_STATS_REGEXP)

    content = JSON.parse(prematched_content['data']) if prematched_content
    profile_data = content.fetch('entry_data', {}).fetch('ProfilePage', []) if content

    if profile_data.nil? || profile_data[0].nil?
      error_message = doc.css("div[class=error-container]").text
      error_header  = doc.css('title').text
      return {result: 'error', body: "Did not get profile page with statistics. Obtained response page \n #{error_header} \n with \n #{error_message} \n content"}
    end

    profile_data = profile_data[0]['graphql']

    el['counts']= {
      'followed_by' => profile_data['user']['edge_followed_by']['count'],
      'media'       => profile_data['user']['edge_owner_to_timeline_media']['count'],
      'follows'     => profile_data['user']['edge_follow']['count']
    }
    el['username'] = profile_data['user']['username']
    el['full_name'] = profile_data['user']['full_name'].to_s
    el['isVerified'] = profile_data['user']['is_verified']
    el['id'] = profile_data['user']['id']
    el['profile_picture'] = profile_data['user']['profile_pic_url']
    el['website'] = profile_data['user']['external_url'].to_s
    el['bio'] = profile_data['user']['biography'].to_s
    return el.merge!({result: 'ok'})
  end
end
