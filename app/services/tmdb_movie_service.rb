require 'uri'
require 'net/http'
require 'json'

class TmdbMovieService
  TMDB_FIND_URL = "https://api.themoviedb.org/3/find/"
  TMDB_MOVIE_DETAILS_URL = "https://api.themoviedb.org/3/movie/"
  TMDB_API_KEY = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhMzRlOGFkYWU5ZWM1MzZkYzUzYzNjMzI1ZTc4MjgwMSIsIm5iZiI6MTcyNzkxMjU4Ny42NjQ2NjYsInN1YiI6IjY2ZjQ3Y2ExZjViNDk3ODY0MzIzMjUwMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.GhE8-BQ2oV7XwFLdfhwZJGr4pH9gUd2uNjxcueMWLgo"

  # Fetch TMDB ID and basic data using IMDb ID
  def self.fetch_movie_by_imdb_id(imdb_id)
    url = URI("#{TMDB_FIND_URL}#{imdb_id}?external_source=imdb_id")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["Authorization"] = TMDB_API_KEY

    response = http.request(request)
    parsed_response = JSON.parse(response.body)

    if parsed_response['movie_results'].any?
      movie_data = parsed_response['movie_results'].first
      # Get additional details using the TMDB ID
      fetch_movie_details(movie_data['id'])
    else
      Rails.logger.warn "No movie found for IMDb ID #{imdb_id}"
      nil
    end
  end

  # Fetch detailed information using TMDB ID
  def self.fetch_movie_details(tmdb_id)
    url = URI("#{TMDB_MOVIE_DETAILS_URL}#{tmdb_id}?language=en-US")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["Authorization"] = TMDB_API_KEY

    response = http.request(request)
    parsed_response = JSON.parse(response.body)

    # Extract detailed information
    {
      tmdb_id: parsed_response['id'],
      title: parsed_response['title'],
      release_date: parsed_response['release_date'],
      budget: parsed_response['budget'],
      revenue: parsed_response['revenue'],
      poster_path: parsed_response['poster_path'],
      runtime: parsed_response['runtime'],
      genres: parsed_response['genres'].map { |genre| genre['name'] },
      overview: parsed_response['overview']
    }
  rescue StandardError => e
    Rails.logger.error "Error fetching movie details for TMDB ID #{tmdb_id}: #{e.message}"
    nil
  end
end
