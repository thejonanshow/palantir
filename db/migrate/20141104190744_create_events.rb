class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.boolean :closed, default: false

      t.timestamps null: false
    end
  end
end
