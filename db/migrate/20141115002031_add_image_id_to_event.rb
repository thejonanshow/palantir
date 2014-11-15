class AddImageIdToEvent < ActiveRecord::Migration
  def change
    add_column :events, :image_id, :integer
  end
end
