require 'rails_helper'

RSpec.describe Palantir::API, :type => :request do
  before(:all) do
    ApiKey.create(secret: 'secret')
  end

  context "POST /api/images" do
    it "returns 200" do
      post "/api/images", :url => 'url', :phash => 'phash'
      expect(response).to have_http_status(:created)
    end

    it "creates an image" do
      expect do
        post "/api/images", :url => 'url', :phash => 'phash'
      end.to change {Image.count}.from(0).to(1)
    end

    it "creates an image with the given url" do
      url = 'test_url'
      post "/api/images", :url => url, :phash => 'phash'
      expect(Image.last.url).to eql(url)
    end

    it "creates an image with the given phash" do
      phash = 'test_phash'
      post "/api/images", :url => 'url', :phash => phash
      expect(Image.last.phash).to eql(phash)
    end

    it "creates an event if the hamming distance is greater than the threshold" do
      first_phash  = '1' * (Image::HAMMING_DISTANCE_THRESHOLD + 1)
      second_phash = '2' * (Image::HAMMING_DISTANCE_THRESHOLD + 1)

      post "/api/images", :url => 'url1', :phash => first_phash

      expect do
        post "/api/images", :url => 'url2', :phash => second_phash
      end.to change {Event.count}.from(0).to(1)
    end
  end
end
