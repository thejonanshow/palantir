class AddDeletedToImage < ActiveRecord::Migration
  def change
    add_column :images, :deleted, :boolean
  end
end
