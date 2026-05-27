class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :source_id

      t.timestamps
    end

    add_index :categories, :slug, unique: true
    add_index :categories, :source_id, unique: true
    add_index :categories, :name
  end
end
