class MoviesController < ApplicationController
  def show
    @movie = TmdbService.fetch_movie_details(params[:id])
    
    if @movie
      # Render your movie details
    else
      # Handle error case
      flash[:error] = "Movie not found."
      redirect_to root_path
    end
  end
end
