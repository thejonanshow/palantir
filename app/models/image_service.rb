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

  def directory_size(directory_name)
    client.directories.get(directory_name).files.length
  end

  def delete_image(image)
    directory = client.directories.get(image.directory_name)
    file = directory.files.head(image.name) if directory
    file.destroy if file
  end

  def delete_directory(directory_name)
    directory = client.directories.get directory_name
    return unless directory

    directory.files.each(&:destroy)
    directory.destroy
  end

  def copy_image(image, target_directory)
    directory = client.directories.get(image.directory_name)
    target_image = directory.files.head(image.name)
    target_image.copy(target_directory, image.name)
  end

  def upload_image(image_path, directory_name, key = nil)
    directory = client.directories.get directory_name
    key ||= File.basename(image_path)
    directory.files.create(key: key, body: File.open(image_path))
  end
end
