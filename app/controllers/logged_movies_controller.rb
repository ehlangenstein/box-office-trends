class LoggedMoviesController < ApplicationController
  def index
    @logged_movies = Movie.all
  end
end
