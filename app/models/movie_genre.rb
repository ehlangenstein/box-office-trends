class MovieGenre < ApplicationRecord
  belongs_to :movie, foreign_key: 'tmdb_id', primary_key: 'tmdb_id'
  belongs_to :genre

   # Ensure that only one genre per movie can be marked as primary
   validate :only_one_primary_genre_per_movie
   private

   def only_one_primary_genre_per_movie
     if primary && movie.movie_genres.where(primary: true).exists?
       errors.add(:primary, "There can only be one primary genre per movie.")
     end
   end
end
