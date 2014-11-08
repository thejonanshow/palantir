require 'rails_helper'

RSpec.describe Event, :type => :model do
  let(:image_service) { ImageService.new }
  let(:event) { Event.new }

  before(:each) do
    event.image_service = image_service
  end

  context "#create" do
    it "creates an event directory name" do
      allow(event).to receive(:create_directory)
      timestamp_regex = /\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}-\d{9}/

      expect(event.directory_name).to match /palantir_event_#{timestamp_regex}/
    end

    it "creates an s3 directory before saving" do
      expect(event).to receive(:create_directory)
      event.save
    end

    it "copies all images to it's s3 directory" do
      allow(event).to receive(:create_directory)
      image = Image.create(deleted: false, url: 'test_url')

      expect(image_service).to receive(:copy_image).with(image, event.directory_name)
      event.save
    end
  end

  context "#create_directory" do
    it "tells the image service to create the directory with the directory name" do
      expect(image_service).to receive(:create_directory).with(event.directory_name)
      event.create_directory
    end
  end
end
