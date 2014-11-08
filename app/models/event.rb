class Event < ActiveRecord::Base
  attr_accessor :image_service

  after_initialize :set_image_service, :set_directory_name
  before_save :create_directory, :copy_images

  def set_image_service
    @image_service = ImageService.new
  end

  def set_directory_name
    self.directory_name = "palantir_event_#{Time.now.strftime '%Y-%m-%d_%H-%M-%S-%9L'}"
  end

  def create_directory
    image_service.create_directory(directory_name)
  end

  def copy_images
    Image.where(deleted: false).each do |image|
      image_service.copy_image(image, directory_name)
    end
  end
end
