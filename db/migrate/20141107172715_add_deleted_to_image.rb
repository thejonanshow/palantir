class AddDeletedToImage < ActiveRecord::Migration
  def change
    add_column :images, :deleted, :boolean, default: false
  end
end
