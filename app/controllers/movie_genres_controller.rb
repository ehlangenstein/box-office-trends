class MovieGenresController < ApplicationController
  def index
    @movie_genres = MovieGenre.includes(:movie, :genre).all
  end

  def update
    @movie_genre = MovieGenre.find(params[:id])

    # Start transaction to ensure both updates succeed
    ActiveRecord::Base.transaction do
      if @movie_genre.update(movie_genre_params)
        # If this genre is set as primary, update the movie's primary_genre
        if @movie_genre.is_primary
          @movie_genre.movie.update!(primary_genre: @movie_genre.genre_id)
        end

        flash[:notice] = "Movie genre updated successfully!"
      else
        flash[:alert] = "Failed to update movie genre."
        raise ActiveRecord::Rollback # Rollback in case of failure
      end
    end

    redirect_to movie_genres_path # Redirect back to the list
  end

  private

  def movie_genre_params
    params.require(:movie_genre).permit(:is_primary)
  end
end
