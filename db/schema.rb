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

ActiveRecord::Schema.define(:version => 20140211132803) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "follows", :force => true do |t|
    t.integer  "followable_id",                      :null => false
    t.string   "followable_type",                    :null => false
    t.integer  "follower_id",                        :null => false
    t.string   "follower_type",                      :null => false
    t.boolean  "blocked",         :default => false, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "follows", ["followable_id", "followable_type"], :name => "fk_followables"
  add_index "follows", ["follower_id", "follower_type"], :name => "fk_follows"

  create_table "item_sales", :force => true do |t|
    t.string   "user_name"
    t.string   "user_level"
    t.float    "item_price"
    t.integer  "item_num"
    t.datetime "buy_time"
    t.integer  "shop_item_id"
  end

  add_index "item_sales", ["shop_item_id"], :name => "index_item_sales_on_shop_item_id"

  create_table "shop_item_content_versions", :force => true do |t|
    t.integer  "shop_item_content_id"
    t.integer  "version"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shop_item_contents", :force => true do |t|
    t.text     "content"
    t.integer  "shop_item_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "version"
  end

  add_index "shop_item_contents", ["shop_item_id"], :name => "index_shop_item_contents_on_shop_item_id"

  create_table "shop_item_versions", :force => true do |t|
    t.integer  "shop_item_id"
    t.integer  "version"
    t.string   "title"
    t.string   "desc"
    t.text     "content"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",       :default => 0
    t.string   "thumb"
  end

  add_index "shop_item_versions", ["shop_item_id"], :name => "index_shop_item_versions_on_shop_item_id"

  create_table "shop_items", :force => true do |t|
    t.string   "title"
    t.string   "desc"
    t.text     "content"
    t.float    "price"
    t.integer  "shop_id"
    t.string   "item_sn"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "comments_count"
    t.integer  "sales_count"
    t.integer  "version"
    t.integer  "status",          :default => 0
    t.datetime "last_check_time"
    t.string   "thumb"
  end

  add_index "shop_items", ["item_sn"], :name => "index_shop_items_on_item_sn", :unique => true
  add_index "shop_items", ["shop_id"], :name => "index_shop_items_on_shop_id"

  create_table "shops", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.integer  "goods_num"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "name",                   :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
