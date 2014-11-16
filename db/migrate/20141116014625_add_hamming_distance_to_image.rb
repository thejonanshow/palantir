class AddHammingDistanceToImage < ActiveRecord::Migration
  def change
    add_column :images, :hamming_distance, :integer
  end
end
