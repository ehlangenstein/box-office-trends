class RemoveMovieIdFromMovieGenres < ActiveRecord::Migration[7.1]
  def change
    remove_column :movie_genres, :movie_id, :integer
  end
end
