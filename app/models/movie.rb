class Movie < ApplicationRecord
  # a movie can have multiple production companies through join table "production_company"
  has_many :production_companies, foreign_key: 'movie_id'
  has_many :companies, through: :production_companies

  # a movie can have multiple genres through movie_genres
  has_many :movie_genres, foreign_key: 'tmdb_id', primary_key: 'tmdb_id'
  has_many :genres, through: :movie_genres

  has_many :credits
  has_many :people, through: :credits


  def self.find_or_create_by_imdb_id(imdb_id)
    movie_data = TmdbMovieService.fetch_movie_by_imdb_id(imdb_id)
    
    if movie_data
      Movie.find_or_create_by(tmdb_id: movie_data[:tmdb_id]) do |movie|
        movie.title = movie_data[:title]
        movie.release_date = movie_data[:release_date]
        movie.budget = movie_data[:budget]
        movie.revenue = movie_data[:revenue]
        movie.poster_path = movie_data[:poster_path]
        # Add any other fields as needed
      end
    else
      Rails.logger.warn "Movie with IMDb ID #{imdb_id} could not be found in TMDB."
      nil
    end
  end
  
end
