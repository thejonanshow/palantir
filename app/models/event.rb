class Event < ActiveRecord::Base
  belongs_to :image

  attr_accessor :image_service, :notification_service, :notifications_enabled,
    :disable_callbacks

  before_save :set_directory_name, :create_directory, :copy_images, :assign_last_image,
    unless: Proc.new { |event| event.disable_callbacks || event.closed }
  after_create :send_notification,
    unless: Proc.new { |event| event.disable_callbacks || event.notifications_disabled? }

  def ignore_callbacks
    disable_callbacks = true
    yield(self)
  ensure
    disable_callbacks = false
  end

  def assign_last_image
    self.image = Image.last
  end

  def image_service
    @image_service ||= ImageService.new
  end

  def notification_service
    @notification_service ||= NotificationService.new
  end

  def notifications_enabled?
    self.notifications_enabled || Rails.env.production?
  end

  def notifications_disabled?
    !notifications_enabled?
  end

  def set_directory_name
    self.directory_name ||= "palantir-event-#{Time.now.strftime '%Y-%m-%d-%H-%M-%S-%9L'}"
  end

  def create_directory
    image_service.create_directory(directory_name)
  end

  def send_notification
    return unless notification_service && Image.last
    url = Rails.application.routes.url_helpers.event_url(self)
    message = "#{Palantir::TWITTER_ALERT}: They draw near: #{Image.last.url}"
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

  def image_urls
    image_service.image_urls(directory_name)
  end

  def remote_image_url
    image_service.remote_image_url_for(self)
  end

  def close_event_if_maximum_images
    update_attribute(:closed, true) if directory_size >= Palantir::MAXIMUM_EVENT_IMAGES
  end
end
