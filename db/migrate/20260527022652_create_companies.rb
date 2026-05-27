class CreateCompanies < ActiveRecord::Migration[7.2]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :logo_url
      t.string :website
      t.text :description
      t.string :industry
      t.string :company_size
      t.string :source_id

      t.timestamps
    end

    add_index :companies, :slug, unique: true
    add_index :companies, :source_id, unique: true
    add_index :companies, :name
  end
end
