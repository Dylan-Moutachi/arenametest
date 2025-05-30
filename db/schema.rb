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

ActiveRecord::Schema[8.0].define(version: 2025_05_25_181839) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.string "booking_number"
    t.string "show"
    t.float "price"
    t.string "last_name"
    t.string "first_name"
    t.integer "age"
    t.string "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ticket_number"
    t.string "booking_date"
    t.string "booking_hour"
    t.string "event_key"
    t.string "event"
    t.string "show_key"
    t.string "show_end_date"
    t.string "show_end_hour"
    t.string "product_type"
    t.string "sales_channel"
    t.string "email"
    t.string "address"
    t.string "postal_code"
    t.string "country"
    t.string "show_date"
    t.string "show_hour"
    t.jsonb "csv_mapping", default: {}
    t.bigint "bookings_import_id"
    t.index ["bookings_import_id"], name: "index_bookings_on_bookings_import_id"
    t.index ["email"], name: "index_bookings_on_email"
    t.index ["show"], name: "index_bookings_on_show"
    t.index ["ticket_number"], name: "index_bookings_on_ticket_number", unique: true
  end

  create_table "bookings_imports", force: :cascade do |t|
    t.string "status"
    t.integer "successes"
    t.jsonb "error_list"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "bookings", "bookings_imports", on_delete: :nullify
end
