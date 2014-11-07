require 'rails_helper'

RSpec.describe Event, :type => :model do
  let(:image_service) { ImageService.new }
  let(:event) { Event.new }

  before(:each) do
    event.image_service = image_service
  end

  context "#create" do
    it "creates an event bucket name" do
      timestamp_regex = /\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}-\d{9}/
      expect(event.bucket_name).to match /palantir_event_#{timestamp_regex}/
    end

    it "creates an s3 bucket before saving" do
      expect(event).to receive(:create_bucket)
      event.save
    end

    it "copies all images to it's s3 bucket" do
      image = Image.create(deleted: false, url: 'test_url')
      expect(image_service).to receive(:copy_image).with(image, event.bucket_name)
      event.save
    end
  end

  context "#create_bucket" do
    it "tells the image service to create the bucket with the bucket name" do
      expect(image_service).to receive(:create_bucket).with(event.bucket_name)
      event.create_bucket
    end
  end
end
