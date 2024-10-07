class MovieGenresController < ApplicationController
  def index
    @movie_genres = MovieGenre.includes(:movie, :genre).all
  end
end
