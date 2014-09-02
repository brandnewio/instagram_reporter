require 'spec_helper'

describe InstagramWebsiteScraper do

  describe '#contact_data_email' do
    it 'gets email data' do
      test_data = "some random text here and there email: luki3k5@server.com and it continues"
      expect(subject.contact_data_email(test_data)).to eq('luki3k5@server.com')
    end
  end

  describe '#find_other_contact_means' do
    let(:keywordless_test_data) { 'I am very cute instagramer here is my bio, like my stuff and comment!' }
    let(:facebook_test_data) { 'I am very cute instagramer if you wish to contact me I am on facebook: luki3k5' }
    let(:business_test_data) { 'For business enquiries please contact my manager at 0987532234 or his office at office@manager.com' }

    it 'delivers result for "facebook" ' do
      expect(subject.find_other_contact_means(facebook_test_data)).to eq(facebook_test_data)
    end

    it 'deliveries result for "business"' do
      expect(subject.find_other_contact_means(business_test_data)).to eq(business_test_data)
    end

    it "doesn't deliver anything if no keyword is found" do
      expect(subject.find_other_contact_means(keywordless_test_data)).to eq(nil)
    end
  end

  let(:luki3k5_web_profile) do
    VCR.use_cassette('get_profile_page') do
      InstagramWebsiteCaller.new.get_profile_page('luki3k5')
    end
  end

  let(:non_existent_web_profile) do
    VCR.use_cassette('get_profile_page') do
      InstagramWebsiteCaller.new.get_profile_page('zxc323terefeere')
    end
  end

  let(:luki3k5_media_file_page) do
    VCR.use_cassette('get_media_file_page') do
       InstagramWebsiteCaller.new.get_media_file_page('http://instagram.com/p/kkfGbfo3kl')
    end
  end

  let(:luki3k5_media_file_page_no_likes_no_comments) do
    VCR.use_cassette('get_media_file_page') do
       InstagramWebsiteCaller.new.get_media_file_page('http://instagram.com/p/HhNH5')
    end
  end

  let(:expected_result_from_scraping) do
    {
      "username"            => "luki3k5",
      "bio"                 => "",
      "website"             => "",
      "profile_picture"     => "http://images.ak.instagram.com/profiles/profile_4907942_75sq_1392804574.jpg",
      "full_name"           => "",
      "counts"              => { "media" => 36, "followed_by" => 34, "follows" => 3 },
      "id"                  => "4907942",
      "contact_data_email"  => nil,
      "other_contact_means" => nil
    }
  end

  describe '#scrape_data_for_profile_page' do
    it 'gets the data from page' do
      expect(subject.scrape_data_for_profile_page(luki3k5_web_profile)).
        to eq(expected_result_from_scraping)
    end
  end

  describe "#get profile page data" do
    it 'returns error if unable to fetch profile page data' do
      VCR.use_cassette('unable to get data') do
        expect(subject.get_profile_statistic(non_existent_web_profile)[:result]).to eq("error")
      end
    end
    
    it 'returns number of media files' do
      VCR.use_cassette('get_number_of_media_files') do
        expect(subject.get_profile_statistic(luki3k5_web_profile)["media"].to_s).to eq("36")
      end
    end
    it 'returns number of followers' do
      VCR.use_cassette('get_number_of_followers') do
        expect(subject.get_profile_statistic(luki3k5_web_profile)["followed_by"].to_s).to eq("34")
      end
    end
    it 'returns number of followed profiles' do
      VCR.use_cassette('get_number_of_followed_profiles') do
        expect(subject.get_profile_statistic(luki3k5_web_profile)["follows"].to_s).to eq("3")
      end
    end

    it 'returns number of commets and likes for media file with given media_id for given profile' do
      VCR.use_cassette('get_likes_and_comments') do
        expect(subject.get_likes_and_comments(luki3k5_media_file_page)[:likes_count]).to eq("2284")
        expect(subject.get_likes_and_comments(luki3k5_media_file_page)[:comments_count]).to eq("20")
      end
    end

    it 'returns number of commets and likes for media file with given media_id for given profile' do
      VCR.use_cassette('get_likes_and_comments_when_none_exist') do
        expect(subject.get_likes_and_comments(luki3k5_media_file_page_no_likes_no_comments)[:likes_count]).to eq("0")
        expect(subject.get_likes_and_comments(luki3k5_media_file_page_no_likes_no_comments)[:comments_count]).to eq("0")
      end
    end
  end
end
