require 'rails_helper'

RSpec.describe ImageService, :type => :model do
  let(:service) { ImageService.new }
  context ".client" do
    it "only creates one client" do
      expect(ImageService.client).to eql(ImageService.client)
    end
  end

  context "#create_bucket" do
    it "creates the bucket with the client" do
      VCR.use_cassette('image_service_creates_bucket') do
        bucket_name = Event.new.generate_bucket_name('test_palantir')
        service.create_bucket(bucket_name)

        expect(service.bucket_exists?(bucket_name)).to be true
      end
    end
  end
end
