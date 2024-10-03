class CreateLoggedMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :logged_movies do |t|
      t.integer "tmdb_id" #id from TMDB API
      #t.date "watch_date" #not in the movies data in TMDB but could be 
      #t.boolean "at_theater" # 1 = watched in theaters 

      t.timestamps
    end
  end
end
