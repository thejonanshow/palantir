class AddBucketNameToEvent < ActiveRecord::Migration
  def change
    add_column :events, :bucket_name, :string
  end
end
