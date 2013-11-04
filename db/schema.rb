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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120113161542) do

  create_table "annotation_bodies", :force => true do |t|
    t.string   "uri"
    t.string   "mime_type"
    t.binary   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "annotation_id"
  end

  create_table "annotation_constraints", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "constrainable_id"
    t.string   "constrainable_type"
    t.binary   "constraint"
    t.string   "constraint_type"
  end

  create_table "annotation_target_infos", :force => true do |t|
    t.string   "uri"
    t.string   "mime_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "annotation_target_instances", :force => true do |t|
    t.integer  "annotation_id"
    t.integer  "annotation_target_info_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "annotations", :force => true do |t|
    t.string   "uri"
    t.string   "author_uri"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "annotations_annotation_target_infos", :force => true do |t|
    t.integer "annotation_id"
    t.integer "annotation_target_info_id"
  end

  create_table "geoname_cities", :force => true do |t|
    t.string   "geo_id"
    t.string   "label"
    t.string   "alt_labels"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "feature_class"
    t.string   "feature_code"
    t.string   "country_code"
    t.string   "alt_country_code"
    t.integer  "population"
    t.integer  "elevation"
    t.string   "timezone"
    t.string   "modification_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ascii_label"
  end

  create_table "text_annotations", :force => true do |t|
    t.string   "annotation_uri"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "xpath"
    t.string   "body"
    t.integer  "text_id"
  end

  create_table "texts", :force => true do |t|
    t.string   "title"
    t.string   "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wikipedia_labels", :force => true do |t|
    t.string "uri"
    t.string "label"
  end

end
