require 'rails_helper'

RSpec.describe ImageService, :type => :model do
  let(:service) { ImageService.new }
  let(:directory_name) { 'test-palantir' }
  let(:image) { Image.create(directory_name: directory_name, name: 'eye_of_sauron.jpg') }

  before(:all) do
    Fog.mock!
  end

  context ".client" do
    it "only creates one client" do
      expect(ImageService.client).to eql(ImageService.client)
    end
  end

  context "#create_directory" do
    it "creates the directory with the client" do
      service.create_directory(directory_name)
      expect(service.directory_exists?(directory_name)).to be true
    end
  end

  context "#delete_directory" do
    it "deletes the directory with the client" do
      service.create_directory(directory_name)
      service.delete_directory(directory_name)

      expect(service.directory_exists?(directory_name)).to be false
    end

    it "does not raise an error if the directory does not exist" do
      expect { service.delete_directory(directory_name) }.to_not raise_error
    end
  end

  context "#image_exists?" do
    it "returns true if the image exists in the target directory" do
      service.create_directory(directory_name)
      service.upload_image('spec/fixtures/eye_of_sauron.jpg', directory_name)
      image = Image.create(directory_name: directory_name, name: 'eye_of_sauron.jpg')

      expect(service.image_exists?(image)).to be true
    end

    it "returns false if the image does not exist in the target directory" do
      service.create_directory(directory_name)
      expect(service.image_exists?(image)).to be false
    end
  end

  context "#directory_exists?" do
    it "returns true if the directory exists" do
      service.create_directory(directory_name)
      expect(service.directory_exists?(directory_name)).to be true
    end

    it "returns false if the directory does not exist" do
      service.delete_directory(directory_name)
      expect(service.directory_exists?(directory_name)).to be false
    end
  end

  context "#copy_image" do
    it "copies the given image to the target directory" do
      service.create_directory(directory_name)
      service.upload_image('spec/fixtures/eye_of_sauron.jpg', directory_name)

      target_directory = "#{directory_name}2"
      service.create_directory(target_directory)

      service.copy_image(image, target_directory)
      image.update_attribute(:directory_name, target_directory)

      expect(service.image_exists?(image)).to be true
    end
  end
end
