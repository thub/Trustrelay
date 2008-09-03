# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080901163810) do

  create_table "apps", :force => true do |t|
    t.integer  "jump_id",     :limit => 11
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.text     "description"
    t.integer  "owner_id",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "location"
    t.string   "state",                     :default => "open"
    t.datetime "closed_at"
  end

  create_table "jumps", :force => true do |t|
    t.integer  "item_id",      :limit => 11,                    :null => false
    t.integer  "parent_id",    :limit => 11
    t.integer  "from_user_id", :limit => 11,                    :null => false
    t.integer  "to_user_id",   :limit => 11,                    :null => false
    t.integer  "jump_count",   :limit => 11
    t.text     "application"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "interest",                   :default => false
    t.text     "comment"
  end

  create_table "relationships", :force => true do |t|
    t.integer  "owner_id",          :limit => 11
    t.integer  "target_id",         :limit => 11
    t.string   "state",                            :default => "pending", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "initiationMessage"
    t.text     "activation_code",   :limit => 255
  end

  create_table "replies", :force => true do |t|
    t.text     "msg"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_id",      :limit => 11, :null => false
    t.integer  "from_user_id", :limit => 11, :null => false
    t.integer  "to_user_id",   :limit => 11, :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                   :default => "passive"
    t.datetime "deleted_at"
    t.string   "password_reset_code",       :limit => 40
    t.boolean  "is_admin",                                :default => false
    t.string   "name",                                                           :null => false
    t.integer  "initiator_id",              :limit => 11
    t.text     "initiationMessage"
    t.boolean  "show_help",                               :default => true
    t.boolean  "accepted",                                :default => false
    t.datetime "accepted_at"
  end

end
