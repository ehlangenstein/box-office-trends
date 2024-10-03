class AddTmdbIdToMovieGenres < ActiveRecord::Migration[7.1]
  def change
    add_column :movie_genres, :tmdb_id, :integer
  end
end
