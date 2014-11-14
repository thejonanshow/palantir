require 'rails_helper'

RSpec.describe ImageService, :type => :model do
  let(:service) { ImageService.new }
  let(:directory_name) { Fabricate.build(:image).directory_name }
  let(:image) { Fabricate(:image) }

  before(:all) do
    Fog.mock!
  end

  after(:each) do
    Fog::Mock.reset
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

  context "#delete_image" do
    it "deletes the image with the client" do
      store_image(image)
      expect {
        service.delete_image(image)
      }.to change { service.image_exists?(image) }.from(true).to(false)
    end

    it "does not raise an error if the image directory does not exist" do
      expect { service.delete_image(image) }.to_not raise_error
    end

    it "does not raise an error if the image does not exist" do
      service.create_directory(directory_name)
      expect { service.delete_image(image) }.to_not raise_error
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
      store_image(image)

      target_directory = "#{directory_name}2"
      service.create_directory(target_directory)

      service.copy_image(image, target_directory)
      image.update_attribute(:directory_name, target_directory)

      expect(service.image_exists?(image)).to be true
    end
  end

  context "#directory_size" do
    it "returns the number of files in the directory" do
      store_image(image)
      store_image(Fabricate(:image, name: 'image2.jpg'))

      expect(service.directory_size(directory_name)).to eql(2)
    end
  end
end
