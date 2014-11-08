require 'rails_helper'

RSpec.describe Palantir::API, :type => :request do
  before(:all) do
    token = 'secret'
    ApiKey.create(token: token)

    @headers = {
      'Authorization' => "Token token=#{token}"
    }

    @image = {
      :url => 'test_image_url',
      :phash => phash('1'),
      :directory_name => 'test_directory_name',
      :name => 'test_image_name.jpg'
    }
  end

  def post_request(image = @image, headers = @headers)
    post "/api/images", { :image => image }, headers
  end

  def phash(char)
    char * (Image::HAMMING_DISTANCE_THRESHOLD + 1)
  end

  context "POST /api/images" do
    it "returns 200" do
      post_request
      expect(response).to have_http_status(:created)
    end

    it "returns 401 if authorization fails" do
      fake_auth_header = { 'Authorization' => "Token token=FAKE" }
      post_request(@image, fake_auth_header)
      expect(response).to have_http_status(:unauthorized)
    end

    it "creates an image" do
      expect do
        post_request
      end.to change {Image.count}.from(0).to(1)
    end

    it "creates an image with the given attributes" do
      post_request

      @image.keys.each do |attribute|
        expect(Image.last.send(attribute)).to eql(@image[attribute])
      end
    end

    it "creates an event if the hamming distance is greater than the threshold" do
      changed_phash = phash('2')
      post_request

      @image[:phash] = changed_phash
      expect do
        post_request
      end.to change {Event.count}.from(0).to(1)
    end
  end
end
