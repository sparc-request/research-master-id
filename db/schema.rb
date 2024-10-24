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

ActiveRecord::Schema.define(version: 2024_09_10_174603) do

  create_table "api_keys", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "audits", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "delayed_jobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "deleted_rmids", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "original_id"
    t.text "long_title"
    t.string "short_title"
    t.integer "creator_id"
    t.integer "pi_id"
    t.integer "sparc_protocol_id"
    t.integer "eirb_protocol_id"
    t.string "research_type"
    t.integer "user_id"
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "explanation"
  end

  create_table "protocols", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "type"
    t.text "short_title"
    t.text "long_title"
    t.bigint "primary_pi_id"
    t.integer "sparc_id"
    t.integer "coeus_id"
    t.string "eirb_id"
    t.string "eirb_institution_id"
    t.string "eirb_state"
    t.date "date_initially_approved"
    t.date "date_approved"
    t.date "date_expiration"
    t.string "sparc_pro_number"
    t.string "mit_award_number"
    t.string "sequence_number"
    t.string "title"
    t.string "entity_award_number"
    t.string "coeus_protocol_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "coeus_project_id"
    t.string "cayuse_project_number"
    t.string "cayuse_pi_name"
    t.string "review_type"
    t.string "irb_review_request"
    t.string "irb_committee_name"
    t.string "external_irb_of_record"
    t.string "other_external_irb_text"
    t.string "clinical_study_phase"
    t.string "status_description"
    t.index ["primary_pi_id"], name: "index_protocols_on_primary_pi_id"
  end

  create_table "research_master_cayuse_relations", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "research_master_id", null: false
    t.bigint "protocol_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["protocol_id"], name: "index_research_master_cayuse_relations_on_protocol_id"
    t.index ["research_master_id"], name: "index_research_master_cayuse_relations_on_research_master_id"
  end

  create_table "research_master_coeus_relations", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "research_master_id", null: false
    t.bigint "protocol_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["protocol_id"], name: "index_research_master_coeus_relations_on_protocol_id"
    t.index ["research_master_id"], name: "index_research_master_coeus_relations_on_research_master_id"
  end

  create_table "research_masters", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "net_id"
    t.string "name"
    t.string "first_name"
    t.string "last_name"
    t.string "middle_initial"
    t.integer "pvid"
    t.string "department"
    t.boolean "admin"
    t.boolean "developer"
    t.boolean "current_interfolio_user"
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

  add_foreign_key "research_masters", "users", column: "creator_id"
  add_foreign_key "research_masters", "users", column: "pi_id"
end
