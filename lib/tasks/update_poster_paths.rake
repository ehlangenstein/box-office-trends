namespace :movies do
  desc "Update poster paths for existing movies from TMDB"
  task update_poster_paths: :environment do
    require 'net/http'
    require 'json'

    TMDB_API_URL = "https://api.themoviedb.org/3"
    TMDB_API_KEY = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhMzRlOGFkYWU5ZWM1MzZkYzUzYzNjMzI1ZTc4MjgwMSIsIm5iZiI6MTcyODMzMDE4OC4xMzc1NTUsInN1YiI6IjY2ZjQ3Y2ExZjViNDk3ODY0MzIzMjUwMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.9zgr_Qw-b4zKf1LuPS8oecGG1usxsqEXWf2HQzkD-yk"

    Movie.find_each do |movie|
      next if movie.poster_path.present?  # Skip movies that already have a poster_path

      # Fetch the movie details from TMDB
      url = URI("#{TMDB_API_URL}/movie/#{movie.tmdb_id}?language=en-US")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["accept"] = 'application/json'
      request["Authorization"] = TMDB_API_KEY

      response = http.request(request)
      movie_data = JSON.parse(response.body)

      if movie_data && movie_data["poster_path"]
        # Update the movie's poster_path
        movie.update(poster_path: movie_data["poster_path"])
        puts "Updated poster_path for movie: #{movie.title}"
      else
        puts "No poster_path found for movie: #{movie.title}"
      end
    end

    puts "Poster path update complete."
  end
end
