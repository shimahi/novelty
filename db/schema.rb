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

ActiveRecord::Schema.define(version: 2019_05_11_105827) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "orders", force: :cascade do |t|
    t.boolean "customer_is_company", default: false
    t.string "customer_name", null: false
    t.string "customer_staff_name"
    t.string "customer_division_name"
    t.string "customer_email", null: false
    t.string "customer_tel", null: false
    t.string "customer_zip", null: false
    t.string "customer_addr1", null: false
    t.string "customer_addr2", null: false
    t.string "customer_addr3"
    t.string "customer_addr4"
    t.string "customer_addr5"
    t.string "customer_addr"
    t.boolean "another_shipping", default: false
    t.boolean "shipping_is_company", default: false
    t.string "shipping_name"
    t.string "shipping_staff_name"
    t.string "shipping_division_name"
    t.string "shipping_tel"
    t.string "shipping_zip"
    t.string "shipping_addr1"
    t.string "shipping_addr2"
    t.string "shipping_addr3"
    t.string "shipping_addr4"
    t.string "shipping_addr5"
    t.string "shipping_addr"
    t.integer "payment_type"
    t.integer "manufacture_plan"
    t.integer "status", default: 0, null: false
    t.date "to_manufacture"
    t.date "to_ship_date"
    t.string "option"
    t.string "memo"
    t.boolean "ordered", default: false
    t.string "payment_token"
    t.boolean "paid_confirmation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_email"], name: "index_orders_on_customer_email"
    t.index ["customer_name"], name: "index_orders_on_customer_name"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "order_id"
    t.string "design"
    t.integer "quantity"
    t.integer "size"
    t.integer "item"
    t.integer "wrapping"
    t.integer "data_status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_products_on_order_id"
  end

  create_table "received_mails", force: :cascade do |t|
    t.bigint "order_id"
    t.string "subject"
    t.text "text"
    t.string "attachment1"
    t.string "attachment2"
    t.string "attachment3"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_received_mails_on_order_id"
  end

  create_table "sent_mails", force: :cascade do |t|
    t.bigint "order_id"
    t.string "subject"
    t.text "text"
    t.string "attachment1"
    t.string "attachment2"
    t.string "attachment3"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_sent_mails_on_order_id"
  end

  add_foreign_key "products", "orders"
  add_foreign_key "received_mails", "orders"
  add_foreign_key "sent_mails", "orders"
end
