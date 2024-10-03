class AddPrimaryToMovieGenres < ActiveRecord::Migration[7.1]
  def change
    add_column :movie_genres, :primary, :boolean
  end
end
