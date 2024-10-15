# app/services/tmdb_wikidata_service.rb
require 'net/http'
require 'json'

class TmdbWikidataService
  TMDB_API_URL = "https://api.themoviedb.org/3"
  TMDB_API_KEY = "your_tmdb_api_key"

  # Fetch the movie data from TMDB by using the Wikidata ID
  def self.fetch_movie_from_wikidata_id(wikidata_id)
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
