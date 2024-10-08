require 'uri'
require 'net/http'
require 'json'

class TmdbMovieGenreService
  TMDB_API_URL = "https://api.themoviedb.org/3"
  TMDB_API_KEY = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhMzRlOGFkYWU5ZWM1MzZkYzUzYzNjMzI1ZTc4MjgwMSIsIm5iZiI6MTcyNzkxMjU4Ny42NjQ2NjYsInN1YiI6IjY2ZjQ3Y2ExZjViNDk3ODY0MzIzMjUwMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.GhE8-BQ2oV7XwFLdfhwZJGr4pH9gUd2uNjxcueMWLgo"

  # Fetch genres for a movie from TMDB and create associations in movie_genres
  def self.fetch_and_store_movie_genres(movie_id)
    url = URI("#{TMDB_API_URL}/movie/#{movie_id}?language=en-US")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["Authorization"] = TMDB_API_KEY

    response = http.request(request)
    movie_data = JSON.parse(response.read_body)

    if movie_data && movie_data["genres"]
      movie = Movie.find_by(tmdb_id: movie_id)
      return unless movie  # Skip if movie not found

      # Loop through each genre and create movie_genre associations
      movie_data["genres"].each do |genre_data|
        genre = Genre.find_or_create_by!(genre_id: genre_data["id"], name: genre_data["name"])

        #Ensure no duplicates created by using find_or_create_by
        movie_genre = MovieGenre.find_or_create_by!(tmdb_id: movie.tmdb_id, genre_id: genre.genre_id) do |mg|
          mg.genre_name = genre.name
        end

        if movie_genre.persisted?
          Rails.logger.info "MovieGenre created for movie #{movie.title} and genre #{genre.name}"
        else 
          Rails.logger.error "Failed to create MovieGenre for #{movie.title}: #{movie_genre.errors.full_messages.join(', ')}"
        end 
        
      end

      Rails.logger.info "Genres for movie #{movie.title} successfully updated."
    else
      Rails.logger.error "Failed to fetch genres for TMDB movie ID #{movie_id}."
    end
  end
end
