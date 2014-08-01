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

ActiveRecord::Schema.define(version: 20120131171008) do

  create_table "dradis_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dradis_configurations", force: true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dradis_evidence", force: true do |t|
    t.integer  "node_id"
    t.integer  "issue_id"
    t.text     "content"
    t.string   "author"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dradis_logs", force: true do |t|
    t.integer  "uid"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dradis_nodes", force: true do |t|
    t.string   "label"
    t.integer  "type_id"
    t.integer  "parent_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dradis_notes", force: true do |t|
    t.string   "author"
    t.text     "text"
    t.integer  "node_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
