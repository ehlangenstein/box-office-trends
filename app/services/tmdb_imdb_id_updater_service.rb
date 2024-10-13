class TmdbImdbIdUpdaterService
  TMDB_API_URL = "https://api.themoviedb.org/3"
  TMDB_API_KEY = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhMzRlOGFkYWU5ZWM1MzZkYzUzYzNjMzI1ZTc4MjgwMSIsIm5iZiI6MTcyODMzMDE4OC4xMzc1NTUsInN1YiI6IjY2ZjQ3Y2ExZjViNDk3ODY0MzIzMjUwMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.9zgr_Qw-b4zKf1LuPS8oecGG1usxsqEXWf2HQzkD-yk"

  # Fetch the IMDb ID for each movie and update the record
  def self.update_imdb_ids
    Movie.all.each do |movie|
      update_imdb_id(movie)
    end
  end

  def self.update_imdb_id(movie)
    url = URI("#{TMDB_API_URL}/movie/#{movie.tmdb_id}?language=en-US")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["Authorization"] = TMDB_API_KEY

    response = http.request(request)
    movie_data = JSON.parse(response.read_body)

    if movie_data && movie_data["imdb_id"]
      movie.update(imdb_id: movie_data["imdb_id"])
      Rails.logger.info "Updated IMDb ID for movie #{movie.title}: #{movie.imdb_id}"
    else
      Rails.logger.error "Failed to fetch IMDb ID for movie #{movie.title} (TMDB ID: #{movie.tmdb_id})"
    end
  end
end
