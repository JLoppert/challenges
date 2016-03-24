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

ActiveRecord::Schema.define(version: 20160206052260) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "employees", force: :cascade do |t|
    t.string "first"
    t.string "last"
  end

  create_table "positions", force: :cascade do |t|
    t.string  "title"
    t.string  "department"
    t.money   "regular",    scale: 2
    t.money   "retro",      scale: 2
    t.money   "other",      scale: 2
    t.money   "overtime",   scale: 2
    t.money   "injury",     scale: 2
    t.money   "detail",     scale: 2
    t.money   "quinn",      scale: 2
    t.money   "total",      scale: 2
    t.integer "zip"
    t.date    "year"
  end

end
