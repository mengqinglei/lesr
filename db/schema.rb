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

ActiveRecord::Schema.define(:version => 20130225045652) do

  create_table "account_groups", :force => true do |t|
    t.string   "name"
    t.integer  "agency_id"
    t.string   "conversion_type"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "separator"
    t.text     "email_setting"
    t.text     "custom_email_text"
    t.datetime "last_emailed_at"
  end

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.integer  "account_group_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "vendor"
  end

  create_table "ad_groups", :force => true do |t|
    t.string   "name"
    t.integer  "campaign_id"
    t.integer  "account_id"
    t.integer  "account_group_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "ad_stats", :force => true do |t|
    t.date     "period"
    t.integer  "impression",       :default => 0
    t.integer  "click",            :default => 0
    t.float    "cost",             :default => 0.0
    t.integer  "conversion",       :default => 0
    t.integer  "ad_id"
    t.integer  "ad_group_id"
    t.integer  "campaign_id"
    t.integer  "account_id"
    t.integer  "account_group_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "ads", :force => true do |t|
    t.string   "headline"
    t.string   "line1"
    t.string   "line2"
    t.string   "display_url"
    t.string   "google_ad_id"
    t.string   "destination_url"
    t.integer  "ad_group_id"
    t.integer  "campaign_id"
    t.integer  "account_id"
    t.integer  "account_group_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "agencies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "campaigns", :force => true do |t|
    t.string   "name"
    t.integer  "account_id"
    t.integer  "account_group_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "domain_stats", :force => true do |t|
    t.date     "period"
    t.string   "name"
    t.integer  "impression",       :default => 0
    t.integer  "click",            :default => 0
    t.float    "cost",             :default => 0.0
    t.integer  "conversion",       :default => 0
    t.integer  "ad_group_id"
    t.integer  "campaign_id"
    t.integer  "account_id"
    t.integer  "account_group_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "type"
  end

  create_table "keyword_stats", :force => true do |t|
    t.date     "period"
    t.string   "name"
    t.integer  "impression",       :default => 0
    t.integer  "click",            :default => 0
    t.float    "cost",             :default => 0.0
    t.integer  "conversion",       :default => 0
    t.float    "position",         :default => 0.0
    t.integer  "ad_group_id"
    t.integer  "campaign_id"
    t.integer  "account_id"
    t.integer  "account_group_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "vendor"
  end

  create_table "uploads", :force => true do |t|
    t.binary   "data"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "upload_type"
    t.datetime "processed_at"
  end

end
