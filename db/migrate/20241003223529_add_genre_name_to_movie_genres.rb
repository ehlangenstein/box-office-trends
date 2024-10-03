class AddGenreNameToMovieGenres < ActiveRecord::Migration[7.1]
  def change
    add_column :movie_genres, :genre_name, :string
  end
end
