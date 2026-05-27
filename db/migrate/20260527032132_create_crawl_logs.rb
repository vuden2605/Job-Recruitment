class CreateCrawlLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :crawl_logs do |t|
      t.integer :status, null: false, default: 0
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :pages_crawled, default: 0
      t.integer :jobs_created, default: 0
      t.integer :jobs_updated, default: 0
      t.integer :jobs_skipped, default: 0
      t.text :error_message
      t.string :triggered_by

      t.timestamps
    end

    add_index :crawl_logs, :status
    add_index :crawl_logs, :started_at
  end
end
