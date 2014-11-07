class ImageService
  def self.client
    @s3_client ||= AWS::S3.new
  end

  def client
    ImageService.client
  end

  def create_bucket(bucket_name)
    client.buckets.create(bucket_name)
  end

  def bucket_exists?(bucket_name)
    client.buckets[bucket_name].exists?
  end

  def delete_bucket(bucket_name)
    client.buckets[bucket_name].delete! if bucket_exists?(bucket_name)
  end
end
