class ModifyMovieGenresTable < ActiveRecord::Migration[7.1]
  def change
    # Remove the default id column
    remove_column :movie_genres, :id, :integer

    # Ensure tmdb_id and genre_id cannot be null
    change_column_null :movie_genres, :tmdb_id, false
    change_column_null :movie_genres, :genre_id, false

    # Add a composite unique index on tmdb_id and genre_id
    add_index :movie_genres, [:tmdb_id, :genre_id], unique: true
  end
end
