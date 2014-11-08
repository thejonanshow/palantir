class AddDirectoryNameToEvent < ActiveRecord::Migration
  def change
    add_column :events, :directory_name, :string
  end
end
