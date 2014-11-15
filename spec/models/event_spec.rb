require 'rails_helper'

RSpec.describe Event, :type => :model do
  let(:image) { Fabricate(:image) }
  let(:image_service) { ImageService.new }
  let(:notification_service_client) { double('notification_service_client') }
  let(:notification_service) { double('notification_service', client: notification_service_client) }

  let(:event) {
    Fabricate(
      :event,
      image_service: image_service,
      notification_service: notification_service
    )
  }

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

    it "sends a notification" do
      url = Rails.application.routes.url_helpers.event_url(event)
      message = "#{Palantir::TWITTER_ALERT}: They draw near: #{url}"
      expect(event.notification_service).to receive(:notify).with(message)
      event.send_notification
    end
  end

  context "#copy_image" do
    it "copies the given image to the event directory" do
      allow_any_instance_of(Image).to receive(:copy_to_open_event_directory)

      expect(image_service).to receive(:copy_image).with(image, event.directory_name)
      event.copy_image(image)
    end

    it "calls close_event_if_maximum_images" do
      allow_any_instance_of(Image).to receive(:copy_to_open_event_directory)
      store_image(image)
      expect(event).to receive(:close_event_if_maximum_images)
      event.copy_image(image)
    end
  end

  context "#directory_size" do
    it "returns the number of images in the event directory" do
      allow_any_instance_of(Image).to receive(:copy_to_open_event_directory)
      store_image(image)
      event.copy_image(image)
      expect(event.directory_size).to eql(1)
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

  context "#image_urls" do
    it "returns a list of urls for all stored images under event" do
      allow_any_instance_of(Image).to receive(:copy_to_open_event_directory)

      store_image(image)
      event.copy_image(image)

      expect(event.image_urls.first).to match(/#{File.basename(image.url)}/)
    end
  end
end
