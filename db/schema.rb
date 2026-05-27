# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_05_27_032132) do
  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "source_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
    t.index ["source_id"], name: "index_categories_on_source_id", unique: true
  end

  create_table "companies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "logo_url"
    t.string "website"
    t.text "description"
    t.string "industry"
    t.string "company_size"
    t.string "source_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_companies_on_name"
    t.index ["slug"], name: "index_companies_on_slug", unique: true
    t.index ["source_id"], name: "index_companies_on_source_id", unique: true
  end

  create_table "crawl_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer "pages_crawled", default: 0
    t.integer "jobs_created", default: 0
    t.integer "jobs_updated", default: 0
    t.integer "jobs_skipped", default: 0
    t.text "error_message"
    t.string "triggered_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["started_at"], name: "index_crawl_logs_on_started_at"
    t.index ["status"], name: "index_crawl_logs_on_status"
  end

  create_table "job_categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_job_categories_on_category_id"
    t.index ["job_id", "category_id"], name: "index_job_categories_on_job_id_and_category_id", unique: true
    t.index ["job_id"], name: "index_job_categories_on_job_id"
  end

  create_table "jobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.bigint "company_id", null: false
    t.bigint "location_id", null: false
    t.string "salary"
    t.text "description"
    t.text "requirements"
    t.string "source_url", null: false
    t.string "source_id"
    t.date "posted_date"
    t.date "expired_date"
    t.integer "status", default: 0, null: false
    t.string "job_type"
    t.integer "experience_level"
    t.integer "job_level", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_jobs_on_company_id"
    t.index ["location_id"], name: "index_jobs_on_location_id"
    t.index ["source_id"], name: "index_jobs_on_source_id", unique: true
    t.index ["source_url"], name: "index_jobs_on_source_url", unique: true
    t.index ["title"], name: "index_jobs_on_title"
  end

  create_table "locations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "region"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_locations_on_name"
    t.index ["slug"], name: "index_locations_on_slug", unique: true
  end

  add_foreign_key "job_categories", "categories"
  add_foreign_key "job_categories", "jobs"
  add_foreign_key "jobs", "companies"
  add_foreign_key "jobs", "locations"
end
