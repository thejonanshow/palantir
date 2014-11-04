class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.boolean :closed

      t.timestamps null: false
    end
  end
end
