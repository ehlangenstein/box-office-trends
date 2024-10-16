class MoviesController < ApplicationController
  def show
    @movie = Movie.find_by(tmdb_id: params[:tmdb_id])
    # Fetch actors (credits with a character)
    @actors = @movie.credits.joins(:person).where.not(character: nil).order(:order)
    
    # Fetch other credits (Writing, Directing, Production)
    @credits = @movie.credits.joins(:person).where(character: nil)
  end
end
