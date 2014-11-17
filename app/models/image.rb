class Image < ActiveRecord::Base
  attr_accessor :disable_callbacks

  after_create :create_event, :copy_to_open_event_directory, :delete_oldest,
    :unless => Proc.new { |image| image.disable_callbacks }

  def create_event
    return unless Image.count > 1
    return unless hamming_distance_exceeds_threshold?

    Event.find_or_create(closed: false)
  end

  def copy_to_open_event_directory
    if event = Event.where(closed: false).first
      event.copy_image(self)
    end
  end

  def hamming_distance_exceeds_threshold?
    previous_image = Image.order(:created_at)[-2]
    return false unless previous_image && previous_image.phash

    set_hamming_distance(previous_image)
    hamming_distance > Palantir::HAMMING_DISTANCE_THRESHOLD
  end

  def set_hamming_distance(other_image)
    hamming = Phashion.hamming_distance(phash.to_i, other_image.phash.to_i)
    update_attribute(:hamming_distance, hamming)
    hamming
  end

  def delete_oldest
    if Image.where(deleted: false).count > Palantir::MAXIMUM_IMAGES
      oldest = Image.where(deleted: false).order(:created_at).first
      oldest.update_attributes(deleted: true)
      oldest.delete_remote
    end
  end

  def delete_remote
    ImageService.new.delete_image(self)
  end
end
