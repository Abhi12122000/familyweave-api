# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_05_18_013325) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "family_tree_nodes", force: :cascade do |t|
    t.bigint "family_tree_id", null: false
    t.bigint "linked_user_id"
    t.string "first_name", null: false
    t.string "last_name"
    t.string "gender"
    t.date "date_of_birth"
    t.date "date_of_death"
    t.boolean "is_placeholder", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_tree_id"], name: "index_family_tree_nodes_on_family_tree_id"
    t.index ["linked_user_id"], name: "index_family_tree_nodes_on_linked_user_id"
  end

  create_table "family_trees", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "privacy_setting", default: "private"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_family_trees_on_user_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "username", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_of_birth"
    t.string "gender"
    t.string "profile_picture_url"
    t.string "cover_photo_url"
    t.string "current_city"
    t.text "bio"
    t.string "relationship_status"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "family_tree_nodes", "family_trees"
  add_foreign_key "family_tree_nodes", "users", column: "linked_user_id"
  add_foreign_key "family_trees", "users"
end
