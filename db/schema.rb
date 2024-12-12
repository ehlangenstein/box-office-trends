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

ActiveRecord::Schema[7.1].define(version: 2024_11_21_053512) do
  create_table "companies", force: :cascade do |t|
    t.integer "company_id"
    t.string "company_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo_path"
    t.boolean "is_top_company"
    t.string "company_group"
  end

  create_table "credits", force: :cascade do |t|
    t.integer "movie_id", null: false
    t.integer "person_id", null: false
    t.string "department"
    t.string "character"
    t.string "role"
    t.string "credit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_credits_on_movie_id"
    t.index ["person_id"], name: "index_credits_on_person_id"
  end

  create_table "distributor_mappings", force: :cascade do |t|
    t.string "distributor_name"
    t.integer "company_id"
    t.index ["distributor_name"], name: "index_distributor_mappings_on_distributor_name", unique: true
  end

  create_table "festival_awards", force: :cascade do |t|
    t.integer "festival_id"
    t.string "award"
    t.integer "award_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "festival_winners", force: :cascade do |t|
    t.integer "award_id"
    t.integer "year"
    t.integer "winner"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "festivals", force: :cascade do |t|
    t.string "festival_name"
    t.integer "festival_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genres", force: :cascade do |t|
    t.integer "genre_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "logged_movies", force: :cascade do |t|
    t.integer "tmdb_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "monthly_box_offices", force: :cascade do |t|
    t.integer "movie_id"
    t.integer "month"
    t.integer "year"
    t.integer "rank"
    t.integer "domestic_gross"
    t.integer "total_theaters"
    t.integer "total_gross"
    t.date "release_date"
    t.string "distributor"
    t.integer "company_id"
    t.index ["company_id"], name: "index_monthly_box_offices_on_company_id"
    t.index ["movie_id"], name: "index_monthly_box_offices_on_movie_id"
  end

  create_table "movie_genres", force: :cascade do |t|
    t.integer "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_primary"
    t.integer "tmdb_id", null: false
    t.string "genre_name"
    t.index ["tmdb_id", "genre_id"], name: "index_movie_genres_on_tmdb_id_and_genre_id", unique: true
  end

  create_table "movies", force: :cascade do |t|
    t.integer "tmdb_id"
    t.string "title"
    t.integer "budget"
    t.string "imdb_id"
    t.date "release_date"
    t.integer "revenue"
    t.integer "primary_genre"
    t.integer "open_wknd_theaters"
    t.integer "open_wknd_BO"
    t.integer "domestic_BO"
    t.integer "intl_BO"
    t.integer "total_BO"
    t.float "RT_audience"
    t.float "RT_critic"
    t.integer "domestic_distrib"
    t.integer "intl_distrib"
    t.integer "director"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "logged"
    t.string "poster_path"
    t.string "distributor"
    t.integer "widest_release_theaters"
    t.integer "wikidata_id"
  end 

  create_table "people", force: :cascade do |t|
    t.integer "person_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "profile_path"
  end

  create_table "production_companies", force: :cascade do |t|
    t.integer "movie_id"
    t.integer "prodco_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "real_name"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "weekly_box_offices", force: :cascade do |t|
    t.integer "movie_id"
    t.integer "week_number"
    t.integer "year"
    t.integer "rank"
    t.integer "rank_last_week", default: 0
    t.integer "weekly_gross"
    t.decimal "gross_change_per_week", precision: 5, scale: 2
    t.integer "total_theaters"
    t.integer "change_theaters_per_week"
    t.integer "per_theater_average_gross"
    t.integer "total_gross"
    t.integer "weeks_in_release"
    t.string "distributor"
    t.integer "company_id"
    t.index ["company_id"], name: "index_weekly_box_offices_on_company_id"
    t.index ["movie_id"], name: "index_weekly_box_offices_on_movie_id"
  end

  create_table "yearly_box_offices", force: :cascade do |t|
    t.integer "movie_id"
    t.integer "year"
    t.integer "rank"
    t.integer "domestic_gross"
    t.integer "total_theaters"
    t.integer "opening_rev"
    t.decimal "percent_of_total", precision: 5, scale: 2
    t.integer "open_wknd_theaters"
    t.date "opening_weekend"
    t.string "distributor"
    t.integer "company_id"
    t.index ["company_id"], name: "index_yearly_box_offices_on_company_id"
    t.index ["movie_id"], name: "index_yearly_box_offices_on_movie_id"
  end

  add_foreign_key "credits", "movies"
  add_foreign_key "credits", "people"
  add_foreign_key "monthly_box_offices", "companies"
  add_foreign_key "monthly_box_offices", "movies"
  add_foreign_key "weekly_box_offices", "companies"
  add_foreign_key "weekly_box_offices", "movies"
  add_foreign_key "yearly_box_offices", "companies"
  add_foreign_key "yearly_box_offices", "movies"
end
