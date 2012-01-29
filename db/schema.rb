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

ActiveRecord::Schema.define(:version => 20120129192136) do

  create_table "comments", :force => true do |t|
    t.string   "body"
    t.boolean  "violation"
    t.integer  "commission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fio"
    t.string   "email"
  end

  create_table "commissions", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.boolean  "is_uik",           :default => false
    t.integer  "election_id"
    t.boolean  "uik_holder",       :default => false
    t.string   "voting_table_url"
    t.boolean  "votes_taken"
  end

  add_index "commissions", ["ancestry"], :name => "index_commissions_on_ancestry"

  create_table "elections", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "voting_labels"
  end

  create_table "pictures", :force => true do |t|
    t.string   "image"
    t.integer  "protocol_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "protocols", :force => true do |t|
    t.integer  "commission_id",                    :null => false
    t.integer  "user_id",                          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "priority"
    t.boolean  "conflict",      :default => false
  end

  add_index "protocols", ["conflict"], :name => "index_protocols_on_conflict"
  add_index "protocols", ["priority"], :name => "index_of_priority"

  create_table "users", :force => true do |t|
    t.string   "email",           :default => ""
    t.string   "password_digest"
    t.string   "name"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  create_table "votings", :force => true do |t|
    t.integer  "protocol_id"
    t.integer  "votes"
    t.integer  "voting_dictionary_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votings", ["protocol_id"], :name => "index_votings_on_protocol_id"
  add_index "votings", ["voting_dictionary_id"], :name => "index_votings_on_voting_dictionary_id"

end
