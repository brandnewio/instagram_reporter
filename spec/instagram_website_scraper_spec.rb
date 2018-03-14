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
    VCR.use_cassette('get_profile_page_non_existent') do
      InstagramWebsiteCaller.new.get_profile_page('zxc323terefeere')
    end
  end

  let(:luki3k5_media_file_page) do
    VCR.use_cassette('get_media_file_page') do
       InstagramWebsiteCaller.new.get_media_file_page('http://instagram.com/p/rbk7ivrf2M')
    end
  end

  let(:luki3k5_media_file_page_no_likes_no_comments) do
    VCR.use_cassette('get_media_file_page') do
       InstagramWebsiteCaller.new.get_media_file_page('http://instagram.com/p/Fw1u1')
    end
  end

  let(:expected_result_from_scraping) do
    {
      "username"            => "luki3k5",
      "bio"                 => "",
      "website"             => "",
      "profile_picture"     => "https://scontent-waw1-1.cdninstagram.com/vp/879498e290707c2c624a667137249cbd/5B32FB93/t51.2885-19/11850251_915632031835791_1153498572_a.jpg",
      "full_name"           => "",
      "counts"              => {"followed_by"=>30, "media"=>37, "follows"=>5},
      "id"                  => "4907942",
      "isVerified" => false,
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
      expect(subject.get_profile_statistic(non_existent_web_profile)[:result]).to eq("error")
    end

    it 'returns number of media files' do
      expect(subject.get_profile_statistic(luki3k5_web_profile)['counts']["media"].to_s).to eq("37")
    end

    it 'returns number of followers' do
      expect(subject.get_profile_statistic(luki3k5_web_profile)['counts']["followed_by"].to_s).to eq("30")
    end

    it 'returns number of followed profiles' do
      expect(subject.get_profile_statistic(luki3k5_web_profile)['counts']["follows"].to_s).to eq("5")
    end

    it 'returns number of commets and likes for media file with given media_id for given profile' do
      expect(subject.get_likes_and_comments(luki3k5_media_file_page)[:likes_count]).to eq("11")
      expect(subject.get_likes_and_comments(luki3k5_media_file_page)[:comments_count]).to eq("1")
    end

    it 'returns number of commets and likes for media file with given media_id for given profile' do
      expect(subject.get_likes_and_comments(luki3k5_media_file_page_no_likes_no_comments)[:likes_count]).to eq("0")
      expect(subject.get_likes_and_comments(luki3k5_media_file_page_no_likes_no_comments)[:comments_count]).to eq("1")
    end

    it 'parses the data correctly' do
      result = VCR.use_cassette('get_profile_page1') do
         InstagramWebsiteCaller.new.get_profile_page('luki3k5')
      end
      subject.get_profile_statistic(result)
    end
  end
end
