class CreateJobs < ActiveRecord::Migration[7.2]
  def change
    create_table :jobs do |t|
      t.string :title
      t.references :company, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.string :salary
      t.text :description
      t.text :requirements
      t.string :source_url, null: false
      t.string :source_id
      t.date :posted_date
      t.date :expired_date
      t.integer :status, default: 0, null: false
      t.string :job_type
      t.integer :experience_level
      t.integer :job_level, default: 0, null: false

      t.timestamps
    end

    add_index :jobs, :source_id, unique: true
    add_index :jobs, :source_url, unique: true
    add_index :jobs, :title
  end
end
