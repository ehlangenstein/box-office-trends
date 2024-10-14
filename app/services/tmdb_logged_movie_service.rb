# app/services/tmdb_movie_service.rb
require 'uri'
require 'net/http'
require 'json'

class TmdbLoggedMovieService
  TMDB_API_URL = "https://api.themoviedb.org/3"
  TMDB_API_KEY = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhMzRlOGFkYWU5ZWM1MzZkYzUzYzNjMzI1ZTc4MjgwMSIsIm5iZiI6MTcyNzkxMjU4Ny42NjQ2NjYsInN1YiI6IjY2ZjQ3Y2ExZjViNDk3ODY0MzIzMjUwMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.GhE8-BQ2oV7XwFLdfhwZJGr4pH9gUd2uNjxcueMWLgo"

  # Fetch the rated movies for the given account and store them in logged_movies
  def self.fetch_and_store_rated_movies(account_id)
    url = URI("#{TMDB_API_URL}/account/#{account_id}/rated/movies?language=en-US&page=1&sort_by=created_at.asc")
    
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["Authorization"] = TMDB_API_KEY

    response = http.request(request)
    rated_movies_data = JSON.parse(response.read_body)

    if rated_movies_data["results"]
      rated_movies_data["results"].each do |movie_data|
        tmdb_id = movie_data["id"]

        # Create the logged_movie entry
        logged_movie = LoggedMovie.find_or_create_by(tmdb_id: tmdb_id)

        # Fetch the movie details and create the movie record if it doesn't exist
        fetch_and_store_movie_details(tmdb_id) 

        # Update the movie's logged status to true
        movie = Movie.find_by(tmdb_id: tmdb_id)
        if movie 
          movie.update(logged: true)
          Rails.logger.info "Updated movie #{movie.title} to set logged status to true."
        else
           Rails.logger.error "Failed to find movie with tmdb_id #{tmdb_id} to update logged status."
        end
      end
    else
      Rails.logger.error "Failed to fetch rated movies from TMDB."
    end
  end

  # Fetch detailed movie information and store it in the movies table
  def self.fetch_and_store_movie_details(movie_id)
    url = URI("#{TMDB_API_URL}/movie/#{movie_id}?language=en-US")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["Authorization"] = TMDB_API_KEY

    response = http.request(request)
    movie_data = JSON.parse(response.read_body)

    if movie_data
      # First, check if the movie already exists, otherwise create it
      movie = Movie.find_or_create_by(tmdb_id: movie_data["id"]) do |m|
        m.title = movie_data["title"]
        m.budget = movie_data["budget"]
        m.imdb_id = movie_data["imdb_id"]
        m.release_date = movie_data["release_date"]
        m.revenue = movie_data["revenue"]
        m.poster_path = movie_data["poster_path"]
      end

      if movie.persisted?
         Rails.logger.info "Movie #{movie.title} successfully found or created."

        #call genre service and log call
        Rails.logger.info "calling TMDB Movie Genre service for movie ID : #{movie.tmdb_id}"
        TmdbMovieGenreService.fetch_and_store_movie_genres(movie.tmdb_id)

        # Call the production company service
        Rails.logger.info "Calling TMDB Production Company service for movie ID: #{movie.tmdb_id}"
        TmdbProdCoService.fetch_and_store_production_companies(movie.tmdb_id)

        # Call the credits service
        Rails.logger.info "Calling TMDB Credits service for movie ID: #{movie.tmdb_id}"
        TmdbCreditsService.fetch_and_store_credits(movie.tmdb_id)
      else
        Rails.logger.error "failed to create or find movie with tmdb id #{movie_id}"
      end
    else
        Rails.logger.error "Failed to fetch movie details for TMDB ID #{movie_id}."
    end
  end
end

# account - 21538508
