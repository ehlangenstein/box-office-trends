class LoggedMoviesController < ApplicationController
  #this is pulling data from the movies table even though im calling it logged movies
  def index
    @logged_movies = Movie.where(logged: true) 
  end

  def edit 
    @movie = Movie.find_by(tmdb_id: params[:tmdb_id])

  end 

  def update
    @movie = Movie.find_by(tmdb_id: params[:tmdb_id])
    if @movie.update(movie_params)
      flash[:notice] = "Movie updated successfully!"
      redirect_to logged_movies_path
    else
      flash[:alert] = "Failed to update movie."
      render :edit
    end
  end
 
  private

  def movie_params
    params.require(:movie).permit(
      :domestic_distrib, 
      :intl_distrib, 
      :open_startDate, 
      :open_endDate, 
      :open_wknd_BO, 
      :domestic_BO, 
      :intl_BO, 
      :total_BO, 
      :open_wknd_theaters, 
      :RT_critic, 
      :RT_audience
    )
  end

end


