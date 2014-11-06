class Image < ActiveRecord::Base
  HAMMING_DISTANCE_THRESHOLD = 10

  after_create :create_event

  def create_event
    return unless Image.count > 1
    return unless hamming_distance_exceeds_threshold?

    Event.create
  end

  def hamming_distance_exceeds_threshold?
    previous_image = Image.order(:created_at)[-2]
    return unless previous_image.phash

    if hamming_distance(previous_image) > HAMMING_DISTANCE_THRESHOLD
      true
    else
      false
    end
  end

  def hamming_distance(other_image)
    return unless phash && other_image.phash && phash.length == other_image.phash.length

    count = 0
    phash.split('').each_with_index do |element, index|
      count += 1 unless element == other_image.phash[index]
    end

    count
  end
end
