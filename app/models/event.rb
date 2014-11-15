class Event < ActiveRecord::Base
  belongs_to :image

  attr_accessor :image_service, :notification_service, :notifications_enabled

  after_initialize :set_image_service, :set_notification_service
  after_create :send_notification, if: Proc.new { |e| e.notifications_enabled? }
  before_save :set_directory_name, :create_directory, :copy_images, unless: Proc.new { |e| e.closed }

  def set_image_service
    self.image_service = ImageService.new
  end

  def set_notification_service
    self.notification_service ||= NotificationService.new
  end

  def notifications_enabled?
    self.notifications_enabled || Rails.env.production?
  end

  def set_directory_name
    self.directory_name ||= "palantir-event-#{Time.now.strftime '%Y-%m-%d-%H-%M-%S-%9L'}"
  end

  def create_directory
    image_service.create_directory(directory_name)
  end

  def send_notification
    return unless notification_service
    url = Rails.application.routes.url_helpers.events_show_url(self)
    message = "#{Palantir::TWITTER_ALERT}: They draw near: #{url}"
    notification_service.notify message
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
