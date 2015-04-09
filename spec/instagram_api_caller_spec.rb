require 'spec_helper'

describe InstagramApiCaller do

  subject { InstagramApiCaller.new }
  let(:test_hashtag) { "inspiredby" }
  let(:test_media_file_id) { '653714645670132444_16192269' }
  let(:non_existent_media_file_id) { '669371381316733323_213058217' }
  let(:test_media_file_with_location_id) {'831138234853764564_4168338'}
  let(:access_token) { '1491324783.1fb234f.a3e00b2881f342e39efb3a0b43941db4' }
  let(:user_id) { '45364550' }

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
        expect(subject.get_user_info_by_access_token(user_id,access_token)['data']['username']).to eq('xiazek')
      end
    end
    it 'returns user data with profile picture link' do
      VCR.use_cassette('get_user_info_by_access_token') do
        expect(subject.get_user_info_by_access_token(user_id,access_token)['data']['profile_picture']).to eq('https://instagramimages-a.akamaihd.net/profiles/profile_45364550_75sq_1378321024.jpg')
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

  describe '#call_api_by_api_token_for_media_file_comments' do
    it 'returns parsed comments' do
      VCR.use_cassette('call_api_by_api_token_for_media_file_comments') do
        response = subject.call_api_by_api_token_for_media_file_comments(test_media_file_id)
        expect(response.class).to eq(Hash)
      end
    end

    it 'gives proper count of comments' do
      VCR.use_cassette('call_api_by_api_token_for_media_file_likes') do
        response = subject.call_api_by_api_token_for_media_file_comments(test_media_file_id)
        expect(response['count']).to eq(23)
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

  describe '#call_api_by_access_token_for_media_file_comments' do
    it 'returns parsed comments' do
      VCR.use_cassette('call_api_by_access_token_for_media_file_comments') do
        response = subject.call_api_by_access_token_for_media_file_comments(test_media_file_id, access_token)
        expect(response.class).to eq(Hash)
      end
    end

    it 'gives proper count of comments' do
      VCR.use_cassette('call_api_by_access_token_for_media_file_likes') do
        response = subject.call_api_by_access_token_for_media_file_comments(test_media_file_id, access_token)
        expect(response['count']).to eq(22)
      end
    end

    it 'returns nil if called for comments for non existing media file' do
      VCR.use_cassette('call_api_by_access_token_for_non_existent_media_file_comments') do
        expected_result = {result: 'error', body: {"meta" => {"error_type" => "APINotFoundError", "code" => 400, "error_message" => "invalid media id"}}}
        response = subject.call_api_by_access_token_for_media_file_comments(non_existent_media_file_id, access_token)
        expect(response).to eq(expected_result)
      end
    end

    xit 'returns nil if called for comments using invalid access_token' do
      VCR.use_cassette('call_api_by_non_existing_access_token_for_media_file_comments') do
        response = subject.call_api_by_access_token_for_media_file_comments(test_media_file_id, access_token)
        expect(response).to be(nil)
      end
    end

  end

  describe '#call_api_by_api_token_for_media_file_likes' do
    it 'returns parsed likes' do
      VCR.use_cassette('call_api_for_media_file_likes') do
        response = subject.call_api_by_api_token_for_media_file_likes(test_media_file_id)
        expect(response.class).to eq(Hash)
      end
    end

    it 'gives proper count of likes' do
      VCR.use_cassette('call_api_for_media_file_likes') do
        response = subject.call_api_by_api_token_for_media_file_likes(test_media_file_id)
        expect(response['count']).to eq(4072)
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

  describe '#call_api_by_access_token_for_media_file_likes' do
    it 'returns parsed likes' do
      VCR.use_cassette('call_api_by_access_token_for_media_file_likes') do
        response = subject.call_api_by_access_token_for_media_file_likes(test_media_file_id, access_token)
        expect(response.class).to eq(Hash)
      end
    end

    it 'gives proper count of likes' do
      VCR.use_cassette('call_api_by_access_token_for_media_file_likes') do
        response = subject.call_api_by_access_token_for_media_file_likes(test_media_file_id, access_token)
        expect(response['count']).to eq(4095)
      end
    end

    it 'returns nil if called for likes for non existing media file' do
      VCR.use_cassette('call_api_by_access_token_for_non_existent_media_file_likes') do
        expected_result = {result: 'error', body: {"meta" => {"error_type" => "APINotFoundError", "code" => 400, "error_message" => "invalid media id"}}}
        response = subject.call_api_by_access_token_for_media_file_likes(non_existent_media_file_id, access_token)
        expect(response).to eq(expected_result)
      end
    end

    xit 'returns nil if called for likes with invalid access token' do
      VCR.use_cassette('call_api_by_non_existing_access_token_for_media_file_likes') do
        response = subject.call_api_by_access_token_for_media_file_likes(test_media_file_id, '16192269.terefere.5132ead0890d4650a196c1f33f8d0748')
        expect(response).to be(nil)
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
        result = subject.get_followers('165640', access_token,'1414444718563')
        expect(result['result']).to eq('ok')
        expect(result['pagination']['next_cursor']).to eq('1414430815337')
        expect(result['data'].size).to eq(49)
      end
    end
  end

end
