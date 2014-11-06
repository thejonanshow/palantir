require 'rails_helper'

RSpec.describe Palantir::API, :type => :request do
  before(:all) do
    ApiKey.create(secret: 'secret')
  end

  context "POST /api/images" do
    it "returns 200" do
      post "/api/images", :image => { :url => 'url', :phash => 'phash' }
      expect(response).to have_http_status(:created)
    end

    it "creates an image" do
      expect do
        post "/api/images", :image => { :url => 'url', :phash => 'phash' }
      end.to change {Image.count}.from(0).to(1)
    end
  end
end
