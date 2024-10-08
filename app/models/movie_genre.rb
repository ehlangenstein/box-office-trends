class MovieGenre < ApplicationRecord
  belongs_to :movie, foreign_key: 'tmdb_id', primary_key: 'tmdb_id'
  belongs_to :genre, foreign_key: 'genre_id'

  # Callback to update the primary_genre in the movies table
  after_update :update_primary_genre_in_movie, if: :is_primary_changed?

  private

  def update_primary_genre_in_movie
    if is_primary == true
      movie.update(primary_genre: genre_id)
    end
  end

end
