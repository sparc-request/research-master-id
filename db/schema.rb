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

ActiveRecord::Schema.define(version: 20170914182636) do

  create_table "api_keys", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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

  create_table "departments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "primary_pis", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.bigint "department_id"
    t.integer "protocol_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_primary_pis_on_department_id"
    t.index ["protocol_id"], name: "index_primary_pis_on_protocol_id"
  end

  create_table "protocols", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "type"
    t.text "short_title"
    t.text "long_title"
    t.integer "sparc_id"
    t.integer "coeus_id"
    t.string "eirb_id"
    t.string "eirb_institution_id"
    t.string "eirb_state"
    t.string "sparc_pro_number"
    t.string "mit_award_number"
    t.string "sequence_number"
    t.string "title"
    t.string "entity_award_number"
    t.string "coeus_protocol_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "research_master_coeus_relations", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "research_master_id", null: false
    t.bigint "protocol_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["protocol_id"], name: "index_research_master_coeus_relations_on_protocol_id"
    t.index ["research_master_id"], name: "index_research_master_coeus_relations_on_research_master_id"
  end

  create_table "research_master_pis", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "email"
    t.string "department"
    t.integer "research_master_id"
    t.index ["research_master_id"], name: "index_research_master_pis_on_research_master_id"
  end

  create_table "research_masters", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "pi_name"
    t.string "department"
    t.text "long_title"
    t.string "short_title"
    t.string "funding_source"
    t.integer "creator_id"
    t.integer "pi_id"
    t.boolean "eirb_validated", default: false
    t.integer "sparc_protocol_id"
    t.integer "eirb_protocol_id"
    t.datetime "eirb_association_date"
    t.datetime "sparc_association_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "research_type"
    t.index ["creator_id"], name: "index_research_masters_on_creator_id"
    t.index ["pi_id"], name: "index_research_masters_on_pi_id"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "email", default: "", null: false
    t.string "name"
    t.boolean "admin"
    t.boolean "developer"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "primary_pis", "departments"
  add_foreign_key "primary_pis", "protocols"
  add_foreign_key "research_master_pis", "research_masters"
  add_foreign_key "research_masters", "users", column: "creator_id"
  add_foreign_key "research_masters", "users", column: "pi_id"
end
