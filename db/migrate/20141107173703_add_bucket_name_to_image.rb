class AddBucketNameToImage < ActiveRecord::Migration
  def change
    add_column :images, :bucket_name, :string
  end
end
