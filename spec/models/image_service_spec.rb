require 'rails_helper'

RSpec.describe ImageService, :type => :model do
  let(:service) { ImageService.new }
  let(:bucket_name) { 'test_palantir' }

  after(:all) do
    return unless online?
    ImageService.new.delete_bucket('test_palantir')
  end

  context ".client" do
    it "only creates one client" do
      expect(ImageService.client).to eql(ImageService.client)
    end
  end

  context "#create_bucket" do
    it "creates the bucket with the client" do
      VCR.use_cassette('image_service_creates_bucket') do
        service.create_bucket(bucket_name)
        expect(service.bucket_exists?(bucket_name)).to be true
      end
    end
  end

  context "#delete_bucket" do
    it "deletes the bucket with the client" do
      VCR.use_cassette('image_service_deletes_bucket') do
        service.create_bucket(bucket_name)
        service.delete_bucket(bucket_name)

        expect(service.bucket_exists?(bucket_name)).to be false
      end
    end

    it "does not raise an error if the bucket does not exist" do
      VCR.use_cassette('image_service_does_not_raise_deleting_nonexistent_bucket') do
        expect { service.delete_bucket(bucket_name) }.to_not raise_error
      end
    end
  end
end
