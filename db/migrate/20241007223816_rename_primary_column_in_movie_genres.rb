class RenamePrimaryColumnInMovieGenres < ActiveRecord::Migration[7.1]
  def change
    # Rename 'primary' to 'is_primary' to avoid keyword conflict
    rename_column :movie_genres, :primary, :is_primary
  end
end
