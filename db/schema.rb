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

ActiveRecord::Schema.define(version: 2019_07_15_202144) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cards", force: :cascade do |t|
    t.string "word"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "game_cards", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "card_id"
    t.integer "type"
    t.integer "address"
    t.boolean "chosen"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_game_cards_on_card_id"
    t.index ["game_id"], name: "index_game_cards_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "game_key", null: false
    t.string "intel_key", null: false
    t.string "invite_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_key"], name: "index_games_on_game_key", unique: true
    t.index ["intel_key"], name: "index_games_on_intel_key", unique: true
    t.index ["invite_code"], name: "index_games_on_invite_code", unique: true
  end

  create_table "guesses", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "game_card_id"
    t.integer "team"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_card_id"], name: "index_guesses_on_game_card_id"
    t.index ["game_id"], name: "index_guesses_on_game_id"
  end

  create_table "hints", force: :cascade do |t|
    t.bigint "game_id"
    t.string "word"
    t.integer "num"
    t.integer "team"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_hints_on_game_id"
  end

  create_table "players", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "game_id"
    t.integer "role"
    t.integer "team"
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_players_on_game_id"
    t.index ["token"], name: "index_players_on_token", unique: true
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "game_cards", "cards"
  add_foreign_key "game_cards", "games"
  add_foreign_key "guesses", "game_cards"
  add_foreign_key "guesses", "games"
  add_foreign_key "hints", "games"
  add_foreign_key "players", "games"
  add_foreign_key "players", "users"
end
