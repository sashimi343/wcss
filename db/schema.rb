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

ActiveRecord::Schema.define(version: 20160207093513) do

  create_table "administrators", force: :cascade do |t|
    t.string   "registration_id"
    t.string   "password_digest", null: false
    t.string   "name"
    t.text     "contact"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "compilations", force: :cascade do |t|
    t.string   "compilation_name"
    t.integer  "administrator_id"
    t.string   "title"
    t.text     "description"
    t.text     "requirement"
    t.datetime "deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "composers", force: :cascade do |t|
    t.string   "registration_id"
    t.string   "password_digest", null: false
    t.string   "name"
    t.text     "contact"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participations", force: :cascade do |t|
    t.integer  "compilation_id"
    t.integer  "composer_id"
    t.string   "song_title"
    t.string   "artist"
    t.string   "comment"
    t.datetime "submission"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
