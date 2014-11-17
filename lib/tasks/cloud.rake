namespace :cloud do
  task :destroy_all => :environment do
    service = ImageService.new
    service.client.directories.each do |directory|
      p "Deleting directory..."

      directory.files.each do |file|
        p "Deleting file #{file.key}"
        file.destroy
      end

      directory.destroy
    end
  end
end
