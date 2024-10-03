class AddPrimaryKeyToMovieGenres < ActiveRecord::Migration[7.1]
  def change
    add_column :movie_genres, :id, :primary_key
  end
end
