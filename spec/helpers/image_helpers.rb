module ImageHelpers
  def phash(char)
    char * (Palantir::HAMMING_DISTANCE_THRESHOLD + 1)
  end

  def store_image(image)
    image_service = ImageService.new
    create_image_directory

    image_service.upload_image(
      'spec/fixtures/eye_of_sauron.jpg',
      image.directory_name,
      image.name
    )
  end

  def create_image_directory
    image_service = ImageService.new
    directory = Fabricate.build(:image).directory_name
    image_service.create_directory(directory) unless image_service.directory_exists?(directory)
  end
end
