class Genre < ApplicationRecord
  #genre can belong to many movies through movie_genres
  has_many :movie_genres
  has_many :movies, through: :movie_genres
end
