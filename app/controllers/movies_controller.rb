class MoviesController < ApplicationController
  def show
    @movie = Movie.find_by(tmdb_id: params[:tmdb_id])

    # Fetch TMDB details if needed
    tmdb_details = TmdbMovieService.fetch_movie_details(@movie.tmdb_id)

    # Extract the backdrop path
    @backdrop_path = tmdb_details["backdrop_path"] if tmdb_details
    

  end
end
