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

ActiveRecord::Schema[8.0].define(version: 2025_10_04_121812) do
  create_table "athlete_competition_events", force: :cascade do |t|
    t.integer "athlete_id", null: false
    t.integer "competition_event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_athlete_competition_events_on_athlete_id"
    t.index ["competition_event_id"], name: "index_athlete_competition_events_on_competition_event_id"
  end

  create_table "athletes", force: :cascade do |t|
    t.string "name"
    t.string "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "klass_id"
    t.string "number"
    t.index ["klass_id"], name: "index_athletes_on_klass_id"
    t.index ["number"], name: "index_athletes_on_number"
  end

  create_table "competition_event_staffs", force: :cascade do |t|
    t.integer "competition_event_id", null: false
    t.integer "staff_id", null: false
    t.string "role_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competition_event_id"], name: "index_competition_event_staffs_on_competition_event_id"
    t.index ["staff_id"], name: "index_competition_event_staffs_on_staff_id"
  end

  create_table "competition_events", force: :cascade do |t|
    t.integer "competition_id", null: false
    t.integer "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competition_id"], name: "index_competition_events_on_competition_id"
    t.index ["event_id"], name: "index_competition_events_on_event_id"
  end

  create_table "competitions", force: :cascade do |t|
    t.string "name"
    t.date "start_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "track_lanes", default: 8, null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.string "event_type"
    t.integer "max_participants"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "avg_time"
    t.string "gender"
  end

  create_table "grades", force: :cascade do |t|
    t.integer "competition_id", null: false
    t.string "name"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competition_id"], name: "index_grades_on_competition_id"
  end

  create_table "heats", force: :cascade do |t|
    t.integer "competition_event_id", null: false
    t.integer "grade_id"
    t.integer "heat_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_lanes", default: 8, null: false
    t.index ["competition_event_id"], name: "index_heats_on_competition_event_id"
    t.index ["grade_id"], name: "index_heats_on_grade_id"
  end

  create_table "klasses", force: :cascade do |t|
    t.integer "grade_id", null: false
    t.string "name"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grade_id"], name: "index_klasses_on_grade_id"
  end

  create_table "lane_athletes", force: :cascade do |t|
    t.integer "lane_id", null: false
    t.integer "athlete_id", null: false
    t.integer "relay_position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_lane_athletes_on_athlete_id"
    t.index ["lane_id"], name: "index_lane_athletes_on_lane_id"
  end

  create_table "lanes", force: :cascade do |t|
    t.integer "heat_id", null: false
    t.integer "lane_number"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["heat_id"], name: "index_lanes_on_heat_id"
  end

  create_table "results", force: :cascade do |t|
    t.integer "lane_id", null: false
    t.integer "athlete_id", null: false
    t.decimal "result_value", precision: 10, scale: 2
    t.integer "rank"
    t.string "status", default: "pending"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_results_on_athlete_id"
    t.index ["lane_id", "athlete_id"], name: "index_results_on_lane_id_and_athlete_id", unique: true
    t.index ["lane_id"], name: "index_results_on_lane_id"
    t.index ["rank"], name: "index_results_on_rank"
  end

  create_table "schedules", force: :cascade do |t|
    t.datetime "scheduled_at"
    t.datetime "end_at"
    t.string "venue"
    t.integer "duration"
    t.string "status", default: "pending"
    t.text "notes"
    t.integer "display_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "heat_id", null: false
    t.index ["heat_id"], name: "index_schedules_on_heat_id"
    t.index ["scheduled_at"], name: "index_schedules_on_scheduled_at"
    t.index ["status"], name: "index_schedules_on_status"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "staffs", force: :cascade do |t|
    t.integer "competition_id", null: false
    t.string "name"
    t.string "role"
    t.string "contact"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competition_id"], name: "index_staffs_on_competition_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "athlete_competition_events", "athletes"
  add_foreign_key "athlete_competition_events", "competition_events"
  add_foreign_key "athletes", "klasses"
  add_foreign_key "competition_event_staffs", "competition_events"
  add_foreign_key "competition_event_staffs", "staffs"
  add_foreign_key "competition_events", "competitions"
  add_foreign_key "competition_events", "events"
  add_foreign_key "grades", "competitions"
  add_foreign_key "heats", "competition_events"
  add_foreign_key "heats", "grades"
  add_foreign_key "klasses", "grades"
  add_foreign_key "lane_athletes", "athletes"
  add_foreign_key "lane_athletes", "lanes"
  add_foreign_key "lanes", "heats"
  add_foreign_key "results", "athletes"
  add_foreign_key "results", "lanes"
  add_foreign_key "schedules", "heats"
  add_foreign_key "sessions", "users"
  add_foreign_key "staffs", "competitions"
end
