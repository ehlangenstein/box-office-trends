# app/services/tmdb_prod_co_service.rb
require 'uri'
require 'net/http'
require 'json'

class TmdbProdCoService
  TMDB_API_URL = "https://api.themoviedb.org/3"
  TMDB_API_KEY = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhMzRlOGFkYWU5ZWM1MzZkYzUzYzNjMzI1ZTc4MjgwMSIsIm5iZiI6MTcyODMzMDE4OC4xMzc1NTUsInN1YiI6IjY2ZjQ3Y2ExZjViNDk3ODY0MzIzMjUwMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.9zgr_Qw-b4zKf1LuPS8oecGG1usxsqEXWf2HQzkD-yk"

  # Fetch and store production companies for a specific movie
  def self.fetch_and_store_production_companies(movie_id)
    url = URI("#{TMDB_API_URL}/movie/#{movie_id}?language=en-US")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["Authorization"] = TMDB_API_KEY

    response = http.request(request)
    movie_data = JSON.parse(response.read_body)

    if movie_data && movie_data["production_companies"]
      movie = Movie.find_by!(tmdb_id: movie_id)
      return unless movie  # Skip if movie not found

      # Loop through each production company
      movie_data["production_companies"].each do |company_data|
        company = Company.find_or_create_by!(company_id: company_data["id"]) do |comp|
          comp.company_name = company_data["name"]
          comp.logo_path = company_data["logo_path"]
        end

        # Now create the record in the production_companies table
        ProductionCompany.find_or_create_by!(movie_id: movie.id, prodco_id: company.company_id)
      end

      Rails.logger.info "Production companies for movie #{movie.title} successfully updated."
    else
      Rails.logger.error "Failed to fetch production companies for TMDB movie ID #{movie_id}."
    end
  end
end
