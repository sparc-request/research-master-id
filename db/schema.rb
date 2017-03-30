# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170330153439) do

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "associated_records", force: :cascade do |t|
    t.integer  "research_master_id", limit: 4
    t.integer  "sparc_id",           limit: 4
    t.integer  "coeus_id",           limit: 4
    t.integer  "eirb_id",            limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "associated_records", ["research_master_id"], name: "index_associated_records_on_research_master_id", using: :btree

  create_table "primary_pis", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "department",  limit: 255
    t.integer  "protocol_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "primary_pis", ["protocol_id"], name: "index_primary_pis_on_protocol_id", using: :btree

  create_table "protocols", force: :cascade do |t|
    t.string   "type",                limit: 255
    t.text     "short_title",         limit: 65535
    t.text     "long_title",          limit: 65535
    t.integer  "sparc_id",            limit: 4
    t.integer  "coeus_id",            limit: 4
    t.string   "eirb_id",             limit: 255
    t.string   "eirb_institution_id", limit: 255
    t.string   "eirb_state",          limit: 255
    t.string   "sparc_pro_number",    limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "research_master_pis", force: :cascade do |t|
    t.string  "name",               limit: 255
    t.string  "email",              limit: 255
    t.string  "department",         limit: 255
    t.integer "research_master_id", limit: 4
  end

  add_index "research_master_pis", ["research_master_id"], name: "index_research_master_pis_on_research_master_id", using: :btree

  create_table "research_masters", force: :cascade do |t|
    t.string   "pi_name",        limit: 255
    t.string   "department",     limit: 255
    t.text     "long_title",     limit: 65535
    t.string   "short_title",    limit: 255
    t.string   "funding_source", limit: 255
    t.boolean  "eirb_validated",               default: false
    t.integer  "user_id",        limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "research_masters", ["user_id"], name: "index_research_masters_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "name",                   limit: 255
    t.boolean  "admin"
    t.boolean  "developer"
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "associated_records", "research_masters"
  add_foreign_key "primary_pis", "protocols"
  add_foreign_key "research_master_pis", "research_masters"
  add_foreign_key "research_masters", "users"
end
