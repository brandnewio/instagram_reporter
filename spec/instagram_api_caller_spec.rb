require 'spec_helper'

describe InstagramApiCaller do

  subject { InstagramApiCaller.new }
  let(:test_hashtag) { "inspiredby" }
  let(:test_media_file_id) { '653714645670132444_16192269' }
  let(:non_existent_media_file_id) { '669371381316733323_213058217' }
  let(:test_media_file_with_location_id) {'831138234853764564_4168338'}
  let(:access_token) { '1491324783.1fb234f.a3e00b2881f342e39efb3a0b43941db4' }
  let(:user_id) { '45364550' }
  let(:emoji_user_id) { '3537544360' }

  describe '#initialize' do
    before(:all) do
      @current_token = InstagramInteractionsBase::API_TOKEN
    end

    it "should raise error if environmental variable INSTAGRAM_API_TOKEN is not set on class initialization" do
      InstagramInteractionsBase::API_TOKEN = nil
      expect { InstagramApiCaller.new }.to raise_error(ArgumentError, 'INSTAGRAM_API_TOKEN environment variable not set')
    end

    after(:all) do
      InstagramInteractionsBase::API_TOKEN = @current_token
    end
  end

  describe '#get_instagram_accounts_by_api_token' do
    it 'returns parsed data' do
      VCR.use_cassette('get_instagram_accounts_by_api_token') do
        expect(subject.get_instagram_accounts_by_api_token['data'].class).to eq(Array)
      end
    end

    it 'returns parsed data' do
      VCR.use_cassette('get_instagram_accounts_by_api_token') do
        expect(subject.get_instagram_accounts_by_api_token['data'].size).to eq(20)
      end
    end
  end

  describe '#get_user_info_by_access_token' do
    it 'returns user data with username' do
      VCR.use_cassette('get_user_info_by_access_token') do
        expect(subject.get_user_info_by_access_token(user_id, access_token)['data']['username']).to eq('xiazek')
      end
    end
    it 'returns user data with profile picture link' do
      VCR.use_cassette('get_user_info_by_access_token') do
        expect(subject.get_user_info_by_access_token(user_id, access_token)['data']['profile_picture']).to eq('https://instagramimages-a.akamaihd.net/profiles/profile_45364550_75sq_1378321024.jpg')
      end
    end
    it 'returns user data with profile picture link' do
      VCR.use_cassette('get_user_info_by_access_token_with_emoji') do
        expect(subject.get_user_info_by_access_token(emoji_user_id, access_token)['data']['profile_picture']).to eq('https://scontent.cdninstagram.com/t51.2885-19/s150x150/13628486_630123880487962_679184041_a.jpg')
      end
    end
  end

  describe '#get_user_info_by_api_token' do
    it 'returns user data with username' do
      VCR.use_cassette('get_user_info_by_api_token') do
        expect(subject.get_user_info_by_api_token(user_id)['data']['username']).to eq('xiazek')
      end
    end
    it 'returns user data with profile picture link' do
      VCR.use_cassette('get_user_info_by_api_token') do
        expect(subject.get_user_info_by_api_token(user_id)['data']['profile_picture']).to eq('https://instagramimages-a.akamaihd.net/profiles/profile_45364550_75sq_1378321024.jpg')
      end
    end
  end

  describe '#get_instagram_accounts_by_access_token' do
    it 'returns parsed data' do
      VCR.use_cassette('get_instagram_accounts_by_access_token') do
        expect(subject.get_instagram_accounts_by_access_token('1491324783.1fb234f.a3e00b2881f342e39efb3a0b43941db4')['data'].class).to eq(Array)
      end
    end

    it 'returns parsed data' do
      VCR.use_cassette('get_instagram_accounts_by_access_token') do
        expect(subject.get_instagram_accounts_by_access_token('1491324783.1fb234f.a3e00b2881f342e39efb3a0b43941db4')['data'].size).to eq(19)
      end
    end
  end

  describe '#get_hashtag_info_by_api_token' do
    it 'returns parsed data' do
      VCR.use_cassette('get_hashtag_info_by_api_token') do
        response = subject.get_hashtag_info_by_api_token(test_hashtag)
        #puts "#{response}"
        expect(response['data'].class).to eq(Array)
      end
    end
    #1395788093935

    it 'returns parsed data with min_id_param' do
      VCR.use_cassette('get_hashtag_info_by_api_token_with_min_id') do
        response = subject.get_hashtag_info_by_api_token(test_hashtag, 1395788093935)
        #puts "#{response}"
        expect(response['data'].class).to eq(Array)
      end
    end

    it 'returns 20 media files infos inside' do
      VCR.use_cassette('get_hashtag_info_by_api_token') do
        response = subject.get_hashtag_info_by_api_token(test_hashtag)
        expect(response['data'].size).to eq(20)
      end
    end
  end

  describe '#get_hashtag_info_by_access_token' do
    it 'returns parsed data' do
      VCR.use_cassette('get_hashtag_info_by_access_token') do
        response = subject.get_hashtag_info_by_access_token(test_hashtag, '1491324783.1fb234f.a3e00b2881f342e39efb3a0b43941db4')
        expect(response['data'].class).to eq(Array)
      end
    end

    it 'returns 20 media files infos inside' do
      VCR.use_cassette('get_hashtag_info_by_access_token') do
        response = subject.get_hashtag_info_by_access_token(test_hashtag, '1491324783.1fb234f.a3e00b2881f342e39efb3a0b43941db4')
        expect(response['data'].size).to eq(20)
      end
    end
  end

  describe '#get_hashtag_media_count_by_access_token' do
    it 'returns the hashtag media count' do
      VCR.use_cassette('get_hashtag_media_count_by_access_token') do
        expect(subject.get_hashtag_media_count_by_access_token(test_hashtag, access_token)['data']['media_count']).to eq(54271)
      end
    end
  end

  describe '#get_hashtag_media_count_by_api_token' do
    it 'returns the hashtag media count' do
      VCR.use_cassette('get_hashtag_media_count_by_api_token') do
        expect(subject.get_hashtag_media_count_by_api_token(test_hashtag)['data']['media_count']).to eq(54271)
      end
    end
  end

  describe '#get_similar_hashtags_by_access_token' do
    it 'returns list of similar hashtags' do
      VCR.use_cassette('get_similar_hashtags_by_access_token') do
        expect(subject.get_similar_hashtags_by_access_token(test_hashtag, access_token)['data'].size).to eq(50)
      end
    end

    it 'returns only one hashtag if tag_name is too short' do
      VCR.use_cassette('get_similar_hashtags_by_access_token') do
        expect(subject.get_similar_hashtags_by_access_token("sun", access_token)['data'].size).to eq(1)
      end
    end
  end

  describe '#get_similar_hashtags_by_api_token' do
    it 'returns list of similar hashtags' do
      VCR.use_cassette('get_similar_hashtags_by_api_token') do
        expect(subject.get_similar_hashtags_by_api_token(test_hashtag)['data'].size).to eq(50)
      end
    end

    it 'returns only one hashtag if tag_name is too short' do
      VCR.use_cassette('get_similar_hashtags_by_access_token') do
        expect(subject.get_similar_hashtags_by_access_token("sun", access_token)['data'].size).to eq(1)
      end
    end
  end

  describe 'call_api_by_api_token_for_media_file_caption' do
    it 'returns parsed caption' do
      VCR.use_cassette('call_api_by_api_token_for_media_file_caption') do
        response = subject.call_api_by_api_token_for_media_file_caption(test_media_file_id)
        expect(response.class).to eq(Hash)
      end
    end
  end

  describe '#call_api_by_access_token_for_media_file_stats' do
    it 'returns likes and comments and hashtags' do
      VCR.use_cassette('call_api_for_media_file_stats') do
        response = subject.call_api_by_access_token_for_media_file_stats('958084286559626921_264734424', access_token)
        expect(response.class).to eq(Hash)
      end
    end
  end

  describe '#call_api_by_access_token_for_media_file_location' do
    it 'returns media file location' do
      VCR.use_cassette('call_api_by_access_token_for_media_file_location') do
        response = subject.call_api_by_access_token_for_media_file_location(test_media_file_with_location_id, access_token)
        expect(response[:result]).to eq('ok')
        expect(response['latitude']).to eq(59.943762911)
        expect(response['longitude']).to eq(30.26491185)
      end
    end

    it 'returns error when there is no location for media file' do
      VCR.use_cassette('call_api_by_access_token_for_media_file_without_location') do
        response = subject.call_api_by_access_token_for_media_file_location(test_media_file_id, access_token)
        expect(response[:result]).to eq('error')
      end
    end
  end

  describe '#get_user_recent_media' do
    let(:access_token) { nil }

    it "returns a response containing media data with image urls etc" do
      VCR.use_cassette('users_user-id_media_recent') do
        result = subject.get_user_recent_media(user_id, access_token)
        expect(result['data'].first['images']['standard_resolution']['url']).to include('http://')
        expect(result['data'].first['user']['id']).to eq(user_id)
      end
    end

    context 'when using access_token' do


      it "returns a response containing media data with image urls etc" do
        VCR.use_cassette('users_user-id_media_recent_by_access_token') do
          result = subject.get_user_recent_media(user_id, access_token)
          expect(result['data'].first['images']['standard_resolution']['url']).to include('http://')
          expect(result['data'].first['user']['id']).to eq(user_id)
        end
      end

    end
  end

  describe '#get_users_by_name' do
    let(:username) { 'goldie_berlin' }
    let(:access_token) { nil }

    it 'returns proper response when called without access token' do
      VCR.use_cassette('users_search_api_token') do
        result = subject.get_users_by_name(username)
        expect(result['data'].first['id']).to eq('165640')
        expect(result['data'].first['username']).to eq('goldie_berlin')
      end
    end

    it "returns a response containing media data with image urls etc" do
      VCR.use_cassette('users_search') do
        result = subject.get_users_by_name(username, access_token)
        puts "#{result.inspect}"
        expect(result['data'].first['id']).to eq('165640')
        expect(result['data'].first['username']).to eq('goldie_berlin')
      end
    end

    context 'when using access_token' do
      let(:access_token) { '1491324783.1fb234f.a3e00b2881f342e39efb3a0b43941db4' }

      it "returns a response containing media data with image urls etc" do
        VCR.use_cassette('users_search_by_access_token') do
          result = subject.get_users_by_name(username, access_token)
          expect(result['data'].first['id']).to eq('165640')
          expect(result['data'].first['username']).to eq('goldie_berlin')
        end
      end
    end
  end

  describe 'get_followers' do
    it 'returns response containing list of followers' do
      VCR.use_cassette('get_user_followers') do
        result = subject.get_followers('165640', access_token, '1414444718563')
        expect(result['result']).to eq('ok')
        expect(result['pagination']['next_cursor']).to eq('1414430815337')
        expect(result['data'].size).to eq(49)
      end
    end
  end

  describe 'get_media_likes_by_access_token' do
    it 'returns list of likes for media file' do
      VCR.use_cassette('get_media_likes_by_access_token') do
        result =
          subject.get_media_likes_by_access_token("696433196675953608_225072619", access_token)
        expect(result['result']).to eq('ok')
        expect(result['data'].size).to eq(15)
      end
    end
  end

  describe 'get_media_comments_by_access_token' do
    it 'returns list of comments for media file' do
      VCR.use_cassette('get_media_comments_by_access_token') do
        result =
          subject.get_media_comments_by_access_token("696433196675953608_225072619", access_token)
        expect(result['result']).to eq('ok')
        expect(result['data'].size).to eq(1)
      end
    end
  end

  describe 'get_user_info_by_api_token_with_invalid_bio' do
    it 'returns user data with coorect bio' do
      VCR.use_cassette('get_user_info_by_api_token_with_invalid_bio') do
        expect(subject.get_user_info_by_api_token(user_id)['data']['bio']).to eq('bemyself💎😏')
      end
    end
  end
end
