class Image < ActiveRecord::Base
  after_create :create_event, :copy_to_open_event_directory, :delete_oldest

  def create_event
    return unless Image.count > 1
    return unless hamming_distance_exceeds_threshold?

    Event.create unless Event.where(closed: false).present?
  end

  def copy_to_open_event_directory
    if event = Event.where(closed: false).first
      event.copy_image(self)
    end
  end

  def hamming_distance_exceeds_threshold?
    previous_image = Image.order(:created_at)[-2]
    return false unless previous_image && previous_image.phash

    hamming_distance(previous_image) > Palantir::HAMMING_DISTANCE_THRESHOLD
  end

  def hamming_distance(other_image)
    return 0 unless phash && other_image.phash && phash.length == other_image.phash.length

    count = 0
    phash.split('').each_with_index do |element, index|
      count += 1 unless element == other_image.phash[index]
    end

    count
  end

  def delete_oldest
    if Image.count > Palantir::MAXIMUM_IMAGES
      oldest = Image.order(:created_at).first
      oldest.update_attributes(deleted: true)
      oldest.delete_remote
    end
  end

  def delete_remote
    ImageService.new.delete_image(self)
  end
end
