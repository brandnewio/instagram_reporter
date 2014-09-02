
    instagram_media_files = []
    JSON.parse(response.body)['data'].each do |el|
      pub = SocialMediaProfile.where(profile_name: el['user']['username']).first
      iu  = InstagramUser.where(username: el['user']['username']).first
      next if iu.blank? && pub.blank? # we skip this loop iteration if there is no user for this media in our DB

      instagram_media_files << InstagramMediaFile.create({
        instagram_username:   el['user']['username'],
        instagram_media_id:   el['id'],
        instagram_type:       el['type'],
        #instagram_user:       iu,
        instagram_link:       el['link'],
        for_observed_ig_tag:  tag,
        instagram_created_at: Time.at(el['created_time'].to_i)
      })
    end
    puts "InstagramHashtagObserver#get_hashtag_info got #{instagram_media_files.size} new InstagramMediaFiles"

