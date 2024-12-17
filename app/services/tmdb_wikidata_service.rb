# app/services/tmdb_wikidata_service.rb
require 'net/http'
require 'json'

class TmdbWikidataService
  TMDB_API_URL = "https://api.themoviedb.org/3"
  TMDB_API_KEY = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhMzRlOGFkYWU5ZWM1MzZkYzUzYzNjMzI1ZTc4MjgwMSIsIm5iZiI6MTcyODMzMDE4OC4xMzc1NTUsInN1YiI6IjY2ZjQ3Y2ExZjViNDk3ODY0MzIzMjUwMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.9zgr_Qw-b4zKf1LuPS8oecGG1usxsqEXWf2HQzkD-yk"

  # Fetch the movie data from TMDB by using the Wikidata ID
  def self.find_wikidata_id(wikidata_id)
    tmdb_url = "#{TMDB_API_URL}/find/#{wikidata_id}?external_source=wikidata_id&api_key=#{TMDB_API_KEY}"
    uri = URI(tmdb_url)

    response = Net::HTTP.get(uri)
    movie_data = JSON.parse(response)

    # Check if movie data is returned and handle results
    if movie_data['movie_results'] && movie_data['movie_results'].any?
      tmdb_movie = movie_data['movie_results'].first

      # Return both the TMDB ID and IMDb ID
      {
        tmdb_id: tmdb_movie['id'],
        imdb_id: tmdb_movie['imdb_id']
      }
    else
      nil
    end
  end
end
