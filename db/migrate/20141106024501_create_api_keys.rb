class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string :secret

      t.timestamps null: false
    end
  end
end
