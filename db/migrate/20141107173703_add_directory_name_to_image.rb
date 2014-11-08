class AddDirectoryNameToImage < ActiveRecord::Migration
  def change
    add_column :images, :directory_name, :string
  end
end
