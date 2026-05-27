class CreateLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :region

      t.timestamps
    end

    add_index :locations, :slug, unique: true
    add_index :locations, :name
  end
end
