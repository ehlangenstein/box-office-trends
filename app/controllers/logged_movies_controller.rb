class LoggedMoviesController < ApplicationController
  def index
    @logged_movies = Movie.all
  end
end
# do i need add the tmdb_movie_service function?
