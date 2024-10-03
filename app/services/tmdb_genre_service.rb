require 'uri'
require 'net/http'
require 'json'

class TmdbGenreService
  TMDB_API_URL = "https://api.themoviedb.org/3/genre/movie/list?language=en"
  TMDB_API_KEY = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhMzRlOGFkYWU5ZWM1MzZkYzUzYzNjMzI1ZTc4MjgwMSIsIm5iZiI6MTcyNzkxMjU4Ny42NjQ2NjYsInN1YiI6IjY2ZjQ3Y2ExZjViNDk3ODY0MzIzMjUwMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.GhE8-BQ2oV7XwFLdfhwZJGr4pH9gUd2uNjxcueMWLgo"

  def self.fetch_and_store_genres
    url = URI(TMDB_API_URL)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["Authorization"] = TMDB_API_KEY

    response = http.request(request)
    genres_data = JSON.parse(response.read_body)

    if genres_data["genres"]
      genres_data["genres"].each do |genre_data|
        # Use find_or_create_by to avoid duplicates
        Genre.find_or_create_by(genre_id: genre_data["id"]) do |genre|
          genre.name = genre_data["name"]
        end
      end
    else
      Rails.logger.error "Failed to fetch genres from TMDB"
    end
  end
end
