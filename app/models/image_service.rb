class ImageService
  def self.client
    @fog ||= Fog::Storage.new(AWS_CONFIG)
  end

  def client
    ImageService.client
  end

  def create_directory(directory_name)
    client.directories.create(key: directory_name)
  end

  def image_exists?(image)
    if client.directories.get(image.directory_name).files.head(image.name)
      true
    else
      false
    end
  end

  def directory_exists?(directory_name)
    if client.directories.get directory_name
      true
    else
      false
    end
  end

  def delete_directory(directory_name)
    directory = client.directories.get directory_name
    return unless directory

    directory.files.each(&:destroy)
    directory.destroy
  end

  def copy_image(image, target_directory)
    target_image = client.directories.get(image.directory_name).files.head(image.name)
    target_image.copy(target_directory, image.name)
  end

  def upload_image(image_path, directory_name)
    directory = client.directories.get directory_name
    directory.files.create(key: File.basename(image_path), body: File.open(image_path))
  end
end
