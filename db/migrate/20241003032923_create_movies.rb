class CreateMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :movies do |t|
      t.integer "tmdb_id" #ext id from tmdb 
      t.string "title" #from TMDB
      t.integer "budget" #from TMDB
      t.integer "imdb_id" #from TMDB
      t.date "release_date" #from TMDB
      t.integer "revenue" #from TMDB - might delete later because need specific BO numbers
      
      # TMDB has multiple genres, i want to select the main one when updating data 
      t.integer "primary_genre"

      t.integer "open_wknd_theaters" # user input; number of theaters for opening weekend
      t.date "open_startDate" #user input
      t.date "open_endDate" #user input
      t.integer "open_wknd_BO" #user input
      t.integer "domestic_BO" #user input
      t.integer "intl_BO" #user input
      t.integer "total_BO" #user input or domestic + intl
      t.float "RT_audience" #user input, Rotton tomatoes audience score
      t.float "RT_critic" #user input, rotton tomatoes critics score 

      t.integer "domestic_distrib" #user input of company ID for domestic distributer, link to companies table
      t.integer "intl_distrib" #user input of company ID for intl distributer, link to companies table

      t.integer "director"  # think i can pull this from TMDB 


      t.timestamps
    end
  end
end
