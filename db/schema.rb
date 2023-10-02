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

ActiveRecord::Schema[7.0].define(version: 2023_10_02_111405) do
  create_table "blob_storages", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.binary "file_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_id"], name: "index_blob_storages_on_blob_id"
  end

  create_table "blobs", force: :cascade do |t|
    t.string "name"
    t.string "uuid"
    t.string "storage_type"
    t.string "size"
    t.string "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_blobs_on_uuid", unique: true
  end

  create_table "local_blob_storages", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "file_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_id"], name: "index_local_blob_storages_on_blob_id"
  end

  create_table "s3_blob_storages", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "s3_key"
    t.string "s3_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_id"], name: "index_s3_blob_storages_on_blob_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "blob_storages", "blobs"
  add_foreign_key "local_blob_storages", "blobs"
  add_foreign_key "s3_blob_storages", "blobs"
end
