require 'rails_helper'

RSpec.describe "Tweather", type: :request do
  city_id = '2172797'

  context 'post weather tweet request with invalid params' do
    it "returns status bad request for non-integer city IDs" do
      tweet('A')
      expect(response).to have_http_status(:bad_request)

      tweet([1, 2, 3])
      expect(response).to have_http_status(:bad_request)

      tweet(nil)
      expect(response).to have_http_status(:bad_request)
    end

    it "returns status not found for unknown city ID" do
      tweet('0')
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'post weather tweet request with valid params' do
    before do
      tweet(city_id)
    end

    it "returns status created for valid city ID" do
      expect(response).to have_http_status(:created)
    end

    it 'returns tweet url and weather text for valid city ID' do
      data = response.parsed_body

      expect(data).to_not be_nil
      expect(data['tweet_url']).to_not be_nil
      expect(data['text']).to_not be_nil
    end

    it 'response has valid tweet url' do
      tweet_reg = /^https:\/\/twitter.com\/[\w]+\/status\/[\d]+\/?$/
      expect(response.parsed_body['tweet_url']).to match(tweet_reg)
    end

    it 'response text shows 6 temperatures' do
      temp_occurences = response.parsed_body['text'].scan(/°C/)
      expect(temp_occurences.count).to eq(6)
    end
  end
end

def tweet(id)
  post "/post?cityId=#{id}"
end