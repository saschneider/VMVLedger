# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_07_11_062212) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "audit_logs", force: :cascade do |t|
    t.integer "user_id"
    t.text "action", null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "contents", force: :cascade do |t|
    t.integer "upload_id", null: false
    t.integer "sequence", null: false
    t.text "field_00"
    t.text "field_01"
    t.text "field_02"
    t.text "field_03"
    t.text "field_04"
    t.text "field_05"
    t.text "field_06"
    t.text "field_07"
    t.text "field_08"
    t.text "field_09"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "field_10"
    t.text "field_11"
    t.text "field_12"
    t.text "field_13"
    t.text "field_14"
    t.text "field_15"
    t.text "field_16"
    t.text "field_17"
    t.text "field_18"
    t.text "field_19"
    t.text "field_20"
    t.text "field_21"
    t.text "field_22"
    t.text "field_23"
    t.text "field_24"
    t.text "field_25"
    t.index ["upload_id", "id"], name: "index_contents_on_upload_id_and_id"
    t.index ["upload_id", "sequence"], name: "index_contents_on_upload_id_and_sequence", unique: true
    t.index ["upload_id"], name: "index_contents_on_upload_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "elections", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "public", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "survey_url"
    t.string "description"
    t.index ["name"], name: "index_elections_on_name", unique: true
  end

  create_table "file_types", force: :cascade do |t|
    t.string "name", null: false
    t.integer "action", default: 0, null: false
    t.string "content_type", null: false
    t.boolean "public", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "sequence", null: false
    t.boolean "convert_to_content", default: false, null: false
    t.text "content_description"
    t.boolean "needed_for_verify", default: false
    t.text "long_description"
    t.string "hint"
    t.integer "stage", default: 0, null: false
    t.boolean "needed_for_status", default: false
    t.index ["name"], name: "index_file_types_on_name", unique: true
    t.index ["sequence"], name: "index_file_types_on_sequence"
  end

  create_table "invitations", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.boolean "redeemed", default: false, null: false
    t.string "creator"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_invitations_on_email", unique: true
  end

  create_table "services", force: :cascade do |t|
    t.boolean "ui_enabled", default: false, null: false
    t.boolean "jobs_enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "nodes"
    t.boolean "download_from_blockchain", default: false
    t.string "retrieve_interval", default: "PT60M", null: false
    t.string "verify_email"
    t.text "full_length_field"
  end

  create_table "uploads", force: :cascade do |t|
    t.integer "election_id", null: false
    t.integer "file_type_id", null: false
    t.integer "status", default: 0, null: false
    t.string "address"
    t.boolean "public", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "checksum"
    t.datetime "retrieved_at"
    t.index ["election_id"], name: "index_uploads_on_election_id"
    t.index ["file_type_id"], name: "index_uploads_on_file_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "forename", default: "", null: false
    t.string "surname", default: "", null: false
    t.boolean "terms_of_service", default: false, null: false
    t.string "time_zone", default: "London", null: false
    t.integer "role", default: 0, null: false
    t.integer "invitation_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_id"], name: "index_users_on_invitation_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

end
