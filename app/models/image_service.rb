class ImageService
  def self.client
    @s3_client ||= AWS::S3.new
  end

  def create_bucket(bucket_name)
    ImageService.client.buckets.create(bucket_name)
  end

  def bucket_exists?(bucket_name)
    ImageService.client.buckets[bucket_name].exists?
  end
end
