class ImageService
  def self.client
    @client ||= AWS::S3.new
  end
end
