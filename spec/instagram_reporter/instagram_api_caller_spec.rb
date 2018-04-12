require 'spec_helper'

describe InstagramApiCaller do

  subject { InstagramApiCaller.new }
  let(:test_hashtag) { "inspiredby" }
  let(:test_media_file_id) { '653714645670132444_16192269' }
  let(:non_existent_media_file_id) { '669371381316733323_213058217' }
  let(:test_media_file_with_location_id) {'1733976787169752478'}
  let(:access_token) { '441979517.b4d2505.74433001c61845adba716152a0e1d3dd' }
  let(:user_id) { '45364550' }
  let(:profile_name) { 'xiazek' }
  let(:emoji_user_id) { '3899278747' }
  let(:instagram_link) { 'https://www.instagram.com/p/1LzJUdRSap/' }

  describe '#initialize' do
    before do
      stub_const("InstagramInteractionsBase::API_TOKEN", nil)
    end

    it "should raise error if environmental variable INSTAGRAM_API_TOKEN is not set on class initialization" do

      expect { InstagramApiCaller.new }.to raise_error(ArgumentError, 'INSTAGRAM_API_TOKEN environment variable not set')
    end
  end

  describe '#get_user_info_by_access_token' do
    it 'returns user data with username' do
      VCR.use_cassette('get_user_info_by_access_token') do
        expect(subject.get_user_info_by_access_token(profile_name, access_token)['data']['username']).to eq('xiazek')
      end
    end

    it 'returns user data with profile picture link' do
      VCR.use_cassette('get_user_info_by_access_token') do
        expect(subject.get_user_info_by_access_token(profile_name, access_token)['data']['profile_picture']).to eq("https://scontent-waw1-1.cdninstagram.com/vp/0bc05807133a21afb32bedd9534c9757/5B633DAB/t51.2885-19/11939555_723875314425165_599316154_a.jpg")
      end
    end

    context 'when private profile' do
      it 'returns error response for private profile' do
        VCR.use_cassette('get_user_recent_media_private') do
          result = subject.get_user_info_by_access_token('maitriye', nil)
          expect(result['result']).to eq('error')
          expect(result['status']).to eq(400)
          expect(result['body']).to match('APINotAllowedError')
          expect(result['body']).to match('you cannot view this resource')
        end
      end
    end

    context 'when profile not found' do
      it 'returns not found error' do
        VCR.use_cassette('get_user_recent_media_not_found_profile') do
          result = subject.get_user_info_by_access_token('some-non-existing-profile-or-deleted-profile', nil)
          expect(result['result']).to eq('error')
          expect(result['status']).to eq(404)
        end
      end
    end
  end

  describe '#get_hashtag_info_by_access_token' do
    it 'returns parsed data' do
      VCR.use_cassette('get_hashtag_info_by_access_token') do
        response = subject.get_hashtag_info_by_access_token(test_hashtag, '441979517.b4d2505.74433001c61845adba716152a0e1d3dd')
        expect(response['data'].class).to eq(Array)
      end
    end

    it 'returns 20 media files infos inside' do
      VCR.use_cassette('get_hashtag_info_by_access_token') do
        response = subject.get_hashtag_info_by_access_token(test_hashtag, '441979517.b4d2505.74433001c61845adba716152a0e1d3dd')
        expect(response['data'].size).to eq(20)
      end
    end
  end

  describe '#get_hashtag_media_count_by_access_token' do
    it 'returns the hashtag media count' do
      VCR.use_cassette('get_hashtag_media_count_by_access_token') do
        expect(subject.get_hashtag_media_count_by_access_token(test_hashtag, access_token)['data']['media_count']).to eq(181697)
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
        expect(subject.get_similar_hashtags_by_access_token("sun", access_token)['data'].size).to eq(50)
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
        response = subject.call_api_by_access_token_for_media_file_stats(instagram_link, access_token)
        expect(response.keys).to contain_exactly('likes', 'comments', 'tags', 'result')
      end
    end
  end

  xdescribe '#call_api_by_access_token_for_media_file_location' do
    it 'returns media file location' do
      VCR.use_cassette('call_api_by_access_token_for_media_file_location') do
        response = subject.call_api_by_access_token_for_media_file_location(test_media_file_with_location_id, access_token)
        expect(response[:result]).to eq('ok')
        expect(response['latitude']).to eq(52.4)
        expect(response['longitude']).to eq(16.9167)
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
    #let(:access_token) { nil }

    context 'when private profile' do
      it 'returns error response for private profile' do
        VCR.use_cassette('get_user_recent_media_private') do
          result = subject.get_user_recent_media(1016919403, 'maitriye')
          expect(result['result']).to eq('error')
          expect(result['status']).to eq(400)
          expect(result['body']).to match('APINotAllowedError')
          expect(result['body']).to match('you cannot view this resource')
        end
      end
    end

    context 'when profile does not have any media' do
      it 'returns success response' do
        VCR.use_cassette('get_user_recent_media_empty_profile') do
          result = subject.get_user_recent_media(6533520937, 'fake')
          expect(result).to eq('data' => [], 'pagination' => nil, 'result' => 'ok')
        end
      end
    end

    context 'when profile not found' do
      it 'returns not found error' do
        VCR.use_cassette('get_user_recent_media_not_found_profile') do
          result = subject.get_user_recent_media(65335237, 'some-non-existing-profile-or-deleted-profile')
          expect(result['result']).to eq('error')
          expect(result['status']).to eq(404)
        end
      end
    end

    it "returns a response containing media data with image urls etc" do
      VCR.use_cassette('users_user-id_media_recent') do
        result = subject.get_user_recent_media(user_id, profile_name)
        expect(result['data'].first['images']['standard_resolution']['url']).to include('https://')
        expect(result['data'].first['user']['id']).to eq(user_id)
      end
    end

    context 'when using access_token' do

      it "returns a response containing media data with image urls etc" do
        VCR.use_cassette('users_user-id_media_recent_by_access_token') do
          result = subject.get_user_recent_media(user_id, profile_name)
          expect(result['data'].first['images']['standard_resolution']['url']).to include('https://')
          expect(result['data'].first['user']['id']).to eq(user_id)
        end
      end

    end
  end

  xdescribe '#get_users_by_name' do
    let(:username) { 'goldie_berlin' }
    #let(:access_token) { nil }

    it "returns a response containing media data with image urls etc" do
      VCR.use_cassette('users_search') do
        result = subject.get_users_by_name(username, access_token)
        puts "#{result.inspect}"
        expect(result['data'].first['id']).to eq('165640')
        expect(result['data'].first['username']).to eq('goldie_berlin')
      end
    end

    context 'when using access_token' do
      let(:access_token) { '441979517.b4d2505.74433001c61845adba716152a0e1d3dd' }

      it "returns a response containing media data with image urls etc" do
        VCR.use_cassette('users_search_by_access_token') do
          result = subject.get_users_by_name(username, access_token)
          expect(result['data'].first['id']).to eq('165640')
          expect(result['data'].first['username']).to eq('goldie_berlin')
        end
      end
    end
  end

  xdescribe 'get_followers' do
    it 'returns response containing list of followers' do
      VCR.use_cassette('get_user_followers') do
        result = subject.get_followers('165640', access_token, '1414444718563')
        expect(result['result']).to eq('ok')
        expect(result['pagination']['next_cursor']).to eq('1414430815337')
        expect(result['data'].size).to eq(49)
      end
    end
  end

  xdescribe 'get_media_likes_by_access_token' do
    it 'returns list of likes for media file' do
      VCR.use_cassette('get_media_likes_by_access_token') do
        result =
          subject.get_media_likes_by_access_token("1733976787169752478", access_token)
        expect(result['result']).to eq('ok')
        expect(result['data'].size).to eq(46)
      end
    end
  end

  xdescribe 'get_media_comments_by_access_token' do
    it 'returns list of comments for media file' do
      VCR.use_cassette('get_media_comments_by_access_token') do
        result =
          subject.get_media_comments_by_access_token("1733976787169752478", access_token)
        expect(result['result']).to eq('ok')
        expect(result['data'].size).to eq(2)
      end
    end
  end
 end
