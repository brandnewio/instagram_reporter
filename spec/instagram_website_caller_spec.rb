require 'spec_helper'

describe InstagramWebsiteCaller do

  describe '#initialize' do
    
    before(:all) do
        @current_token = InstagramInteractionsBase::API_TOKEN
    end

    it 'has proper Faraday connection object' do
      expect(subject.website_connection.class).to be(Faraday::Connection)
    end

    it "should raise error if environmental variable INSTAGRAM_API_TOKEN is not set on class initialization" do
      InstagramInteractionsBase::API_TOKEN = nil
      expect{InstagramWebsiteCaller.new}.to raise_error(ArgumentError, 'INSTAGRAM_API_TOKEN environment variable not set')
    end
    
    it "should assign envirnomental variable to appropriate class variable if env variable is not empty" do
      InstagramInteractionsBase::API_TOKEN ="SAMPLE_API_TOKEN"
      expect(InstagramWebsiteCaller::API_TOKEN).to eq("SAMPLE_API_TOKEN") 
    end

     after(:all) do
       InstagramInteractionsBase::API_TOKEN = @current_token
     end
  end

  describe '#get_profile_page' do
    it 'returns website' do
      VCR.use_cassette('get_profile_page') do
        expect(subject.get_profile_page('luki3k5')).not_to be(nil)
      end
    end
  end
end
