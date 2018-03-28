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

ActiveRecord::Schema.define(version: 20180328130651) do

  create_table "transactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "txid", null: false
    t.string "address", null: false
    t.string "ip_address", null: false
    t.date "date", null: false
    t.float "value", limit: 24, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["created_at"], name: "index_transactions_on_created_at"
    t.index ["date"], name: "index_transactions_on_date"
    t.index ["type", "ip_address", "address", "date"], name: "index_transactions_on_type_and_ip_address_and_address_and_date", unique: true
    t.index ["type"], name: "index_transactions_on_type"
  end

end
