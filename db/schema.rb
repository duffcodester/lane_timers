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

ActiveRecord::Schema[8.1].define(version: 2026_02_21_142205) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.time "end_time", null: false
    t.integer "lane", null: false
    t.string "name"
    t.string "phone"
    t.time "start_time", null: false
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["lane", "date", "start_time"], name: "index_bookings_on_lane_and_date_and_start_time", unique: true
    t.index ["team_id"], name: "index_bookings_on_team_id"
  end

  create_table "meet_sessions", force: :cascade do |t|
    t.boolean "break_period", default: false, null: false
    t.boolean "closed", default: false, null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.time "end_time", null: false
    t.bigint "meet_id"
    t.string "name"
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_meet_sessions_on_date"
    t.index ["meet_id"], name: "index_meet_sessions_on_meet_id"
  end

  create_table "meets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "location"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key"
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.string "abbreviation"
    t.string "address"
    t.string "coach"
    t.string "color"
    t.datetime "created_at", null: false
    t.string "email"
    t.decimal "misc_expense", precision: 10, scale: 2, default: "0.0"
    t.string "name", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_teams_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "bookings", "teams"
  add_foreign_key "meet_sessions", "meets"
end
