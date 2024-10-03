class Movie < ApplicationRecord
  # a movie can have multiple production companies through join table "production_company"
  has_many :production_companies
  has_many :companies, through: :production_companies

  # a movie can have multiple genres through movie_genres
  has_many :movie_genres, foreign_key: 'tmdb_id', primary_key: 'tmdb_id'
  has_many :genres, through: :movie_genres
end
