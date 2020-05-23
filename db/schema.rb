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

ActiveRecord::Schema.define(version: 2020_05_22_161517) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "line_one"
    t.string "line_two"
    t.string "zipcode"
    t.string "city"
    t.string "state"
    t.string "country"
    t.bigint "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_addresses_on_contact_id"
  end

  create_table "blacklist", force: :cascade do |t|
    t.string "jti", null: false
    t.index ["jti"], name: "index_blacklist_on_jti"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_taggings", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "company_id"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_taggings_on_company_id"
    t.index ["user_id"], name: "index_company_taggings_on_user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.bigint "company_id"
    t.float "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "phone"
    t.index ["company_id"], name: "index_contacts_on_company_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "contact_id"
    t.bigint "company_id"
    t.string "contact_name"
    t.float "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "bill_number"
    t.index ["company_id"], name: "index_projects_on_company_id"
    t.index ["contact_id"], name: "index_projects_on_contact_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "company_id"
    t.bigint "contact_id"
    t.bigint "transaction_id"
    t.bigint "parent_id"
    t.string "description"
    t.string "category"
    t.string "bill_number"
    t.date "date"
    t.float "amount"
    t.float "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_type"
    t.string "cheque_number"
    t.index ["company_id"], name: "index_transactions_on_company_id"
    t.index ["contact_id"], name: "index_transactions_on_contact_id"
    t.index ["parent_id"], name: "index_transactions_on_parent_id"
    t.index ["project_id"], name: "index_transactions_on_project_id"
    t.index ["transaction_id"], name: "index_transactions_on_transaction_id"
  end

  create_table "user_invites", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "user_id"
    t.string "role"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_user_invites_on_company_id"
    t.index ["user_id"], name: "index_user_invites_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "role"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.bigint "company_id"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "addresses", "contacts"
  add_foreign_key "company_taggings", "companies"
  add_foreign_key "company_taggings", "users"
  add_foreign_key "contacts", "companies"
  add_foreign_key "projects", "companies"
  add_foreign_key "projects", "contacts"
  add_foreign_key "transactions", "companies"
  add_foreign_key "transactions", "contacts"
  add_foreign_key "transactions", "projects"
  add_foreign_key "user_invites", "companies"
  add_foreign_key "user_invites", "users"
  add_foreign_key "users", "companies"
end
