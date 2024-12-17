# app/services/tmdb_movie_service.rb
require 'uri'
require 'net/http'
require 'json'

class TmdbLoggedMovieService
  TMDB_API_URL = "https://api.themoviedb.org/3"
  TMDB_API_KEY = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhMzRlOGFkYWU5ZWM1MzZkYzUzYzNjMzI1ZTc4MjgwMSIsIm5iZiI6MTcyODMzMDE4OC4xMzc1NTUsInN1YiI6IjY2ZjQ3Y2ExZjViNDk3ODY0MzIzMjUwMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.9zgr_Qw-b4zKf1LuPS8oecGG1usxsqEXWf2HQzkD-yk"

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
          
          # Use the BoxOfficeMojoScraper to fetch additional box office data
          box_office_data = BoxOfficeMojoService.fetch_and_store_box_office_data(movie.imdb_id)
          if box_office_data
            movie.update(
              open_wknd_theaters: box_office_data[:opening_theaters],
              open_wknd_BO: box_office_data[:opening_weekend_box_office],
              domestic_BO: box_office_data[:domestic_box_office],
              intl_BO: box_office_data[:international_box_office],
              distributor: box_office_data[:distributor],
              widest_release_theaters: box_office_data[:widest_release]
            )
            Rails.logger.info "Updated movie #{movie.title} with Box Office Mojo data."
          else
            Rails.logger.error "Failed to fetch Box Office data for #{movie.title}"
          end
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
      # Fetch the external IDs (including Wikidata ID)
      wikidata_id = fetch_wikidata_id(movie_id)

      # First, check if the movie already exists, otherwise create it
      movie = Movie.find_or_create_by(tmdb_id: movie_data["id"]) do |m|
        m.title = movie_data["title"]
        m.budget = movie_data["budget"]
        m.imdb_id = movie_data["imdb_id"]
        m.release_date = movie_data["release_date"]
        m.revenue = movie_data["revenue"]
        m.poster_path = movie_data["poster_path"]
      end
      
      # Explicitly update the wikidata_id, as find_or_create_by won't update it outside the block
      if movie.wikidata_id.blank? && wikidata_id.present?
        movie.update(wikidata_id: wikidata_id)
        Rails.logger.info "Updated Wikidata ID for movie #{movie.title} to #{wikidata_id}"
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

  def self.fetch_wikidata_id(movie_id)
    url = URI("#{TMDB_API_URL}/movie/#{movie_id}/external_ids")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["Authorization"] = TMDB_API_KEY

    response = http.request(request)
    external_ids = JSON.parse(response.read_body)

    external_ids["wikidata_id"] # Return the Wikidata ID
  rescue => e
    Rails.logger.error "Error fetching Wikidata ID for movie ID #{movie_id}: #{e.message}"
    nil
  end
end


# account - 21538508
