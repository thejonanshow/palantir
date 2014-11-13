class Event < ActiveRecord::Base
  attr_accessor :image_service

  after_initialize :set_image_service
  before_save :set_directory_name, :create_directory, :copy_images, unless: Proc.new { |e| e.closed }

  def set_image_service
    @image_service = ImageService.new
  end

  def set_directory_name
    self.directory_name ||= "palantir-event-#{Time.now.strftime '%Y-%m-%d-%H-%M-%S-%9L'}"
  end

  def create_directory
    image_service.create_directory(directory_name)
  end

  def copy_image(image)
    image_service.copy_image(image, directory_name)
    close_event_if_maximum_images
  end

  def copy_images
    Image.where(deleted: false).each do |image|
      copy_image(image)
    end
  end

  def directory_size
    image_service.directory_size(directory_name)
  end

  def close_event_if_maximum_images
    update_attribute(:closed, true) if directory_size >= Palantir::MAXIMUM_EVENT_IMAGES
  end
end
