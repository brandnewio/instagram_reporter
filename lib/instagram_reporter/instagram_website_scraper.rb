class InstagramWebsiteScraper

  SEARCHABLE_KEYWORDS = %w(contact business Business Facebook facebook fb email Twitter twitter Contact FB tumblr Blog blog mail http www)
  EMAIL_PATTERN_MATCH = /([^@\s*]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})/i

  def contact_data_email(data)
    matched = data.match(EMAIL_PATTERN_MATCH)
    return matched.to_s if matched != nil
    nil
  end

  def find_other_contact_means(data)
    return data.gsub(',', '') if data.match(EMAIL_PATTERN_MATCH) != nil

    SEARCHABLE_KEYWORDS.each do |ci|
      return data.gsub(',', '') if data.include?(ci)
    end
    return nil
  end

  def scrape_data_for_profile_page(html)
    returnee = nil
    doc = Nokogiri::HTML(html)
    #el = JSON.parse(doc.content.match(/{"entry_data":{.*}/).to_s)
    prematched_content = doc.content.match(/"prerelease":.*"}/).to_s
    match_for_profile_data = prematched_content.match(/{.*"id":"\d+"}/).to_s
    el = JSON.parse(match_for_profile_data)
    #returnee = el['entry_data']['UserProfile'][0]['user']
    el['contact_data_email']  = contact_data_email(el['bio'])
    el['other_contact_means'] = find_other_contact_means(el['bio'])
    el
  end

  def get_likes_and_comments(html)
    returnee         = {status: 'online'}
    doc              = Nokogiri::HTML(html)
    likes_content    = doc.content.match(/"likes":\{"count":[0-9]+(?:\.[0-9]*)?/).to_s
    likes            = likes_content.match(/[0-9][0-9]*/).to_s
    comments_content = doc.content.match(/"comments":{"nodes":\[.*?\]}/).to_s
    comments         = comments_content.scan(/"id":"[0-9]*"/)
    return {result: 'error', body: 'could not scrape web page for likes and comments'} if likes.nil? || comments.nil?
    # instagram media file removed
    returnee.merge!({status: 'offline',result: 'error', body:'Page not found for media file'}) if !doc.content.match(/Page Not Found/).nil?
    returnee.merge!({result: 'ok', likes_count: likes, comments_count: comments.size.to_s})
  end

  def get_profile_statistic(html)
    doc = Nokogiri::HTML(html)
    doc_match =doc.content.match(/{"media":.*\d}/)
    if doc_match.nil?
      error_message = doc.css("div[class=error-container]").text
      error_header  = doc.css('title').text
      return {result: 'error', body: "Did not get profile page with statistics. Obtained response page \n #{error_header} \n with \n #{error_message} \n content"}
    end
    returnee  = eval(doc_match.to_s.gsub(":","=>"))
    prematched_content = doc.content.match(/"prerelease":.*"}/).to_s
    match_for_profile_picture = prematched_content.match(/{.*"id":"\d+"}/).to_s
    #el = JSON.parse(doc.content.match(/{"entry_data":{.*}/).to_s)
    el = JSON.parse(match_for_profile_picture)
    #result = el['entry_data']['UserProfile'][0]['user']
    return returnee.merge!({result: 'ok', profile_picture: el['profile_picture']})
  end
end
