require 'rails_helper'

RSpec.describe Event, :type => :model do
  let(:image) { Fabricate(:image) }
  let(:image_service) { ImageService.new }
  let(:event) { Fabricate(:event) }

  before(:all) do
    Fog.mock!
  end

  before(:each) do
    Fog::Mock.reset
    event.image_service = image_service
  end

  context "#create" do
    it "creates an event directory name" do
      allow(event).to receive(:create_directory)
      timestamp_regex = /\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}-\d{9}/

      event.directory_name = nil
      event.set_directory_name
      expect(event.directory_name).to match /palantir-event-#{timestamp_regex}/
    end

    it "creates an s3 directory before saving" do
      expect(event).to receive(:create_directory)
      event.save
    end

    it "copies all images to it's s3 directory" do
      allow(event).to receive(:create_directory)
      allow_any_instance_of(Image).to receive(:copy_to_open_event_directory)

      event.set_directory_name
      expect(image_service).to receive(:copy_image).with(image, event.directory_name)
      event.save
    end
  end

  context "#copy_image" do
    it "copies the given image to the event directory" do
      allow_any_instance_of(Image).to receive(:copy_to_open_event_directory)
      expect(image_service).to receive(:copy_image).with(image, event.directory_name)
      event.copy_image(image)
    end
  end

  context "#create_directory" do
    it "tells the image service to create the directory with the directory name" do
      expect(image_service).to receive(:create_directory).with(event.directory_name)
      event.create_directory
    end
  end

  context "#close_event_if_maximum_images" do
    it "closes the event if the event directory has 100 or more images" do
      event.set_directory_name
      event.create_directory
      allow(event.image_service).to receive(:directory_size).and_return(Palantir::MAXIMUM_EVENT_IMAGES)
      expect { event.close_event_if_maximum_images }.to change { event.closed }.from(false).to(true)
    end
  end
end
