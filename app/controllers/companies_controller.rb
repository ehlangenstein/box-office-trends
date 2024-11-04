class CompaniesController < ApplicationController

  require 'net/http'
  require 'json'

  TMDB_API_URL = "https://api.themoviedb.org/3"
  TMDB_API_KEY = "a34e8adae9ec536dc53c3c325e782801"


  def index
      # Fetch only companies that are associated with movies in the logged_movies table
    @companies = Company.joins(:production_companies).distinct
  end

  def show
     # Find the company in the database
    @company = Company.find_by("company_id" => params["id"])

    # If the company isn't in the local database, fetch it from the TMDB API and add it to the local database
    if @company.nil?
       Rails.logger.info "Company not found in the database, fetching from TMDB..."
      
       company_data = fetch_company_details_from_tmdb(params[:id])

      if company_data
        Rails.logger.info "Company found on TMDB: #{company_data["name"]}"
        @company = OpenStruct.new(
          company_id: company_data["id"],
          company_name: company_data["name"],
          logo_path: company_data["logo_path"]
      )
      else
        Rails.logger.error "Company not found on TMDB for ID: #{params[:id]}"
      return
    end
  end

    # If the company is Neon, fetch the list of movies using the scraper
    if @company.company_id == 90733
      @neon_movies = NeonFilmsWikiScraper.new.fetch_movies
      Rails.logger.info "Fetched #{@neon_movies.size} movies from Wikipedia."
      
      @movies_data = @neon_movies.map do |movie|
        # Use the updated TmdbWikidataService to fetch both TMDB and IMDb IDs
        movie_ids = TmdbWikidataService.fetch_movie_from_wikidata_id(movie[:wikidata_id])
      
        if movie_ids 
          imdb_id = movie_ids[:imdb_id]
          tmdb_id = movie_ids[:tmdb_id]
          box_office_data = fetch_box_office_data(imdb_id) if imdb_id
          {
            title: movie[:title],
            tmdb_id: tmdb_id,
            imdb_id: imdb_id,
            box_office_data: box_office_data
          }
        else
          {
            title: movie[:title],
            tmdb_id: 'N/A',
            imdb_id: 'N/A',
            box_office_data: 'N/A'
          }
        end
      end
    else
      @neon_movies = [] # Default for companies without a movie list from Wikipedia
      Rails.logger.info "IDK"
    end


     # Find the movies associated with the company in the logged movies table
    @movies = Movie.joins(:production_companies).where(production_companies: { prodco_id: @company.company_id }) 

     # Fetch the movies from TMDB API
     fetch_company_movies_from_api(@company.company_id)
  end 




  def search
    if params[:query].present?
      search_companies_in_tmdb(params[:query])
    end
  end





  def top_companies
    @top_companies = Company.top_companies
  end




  def add_company
    company_data = fetch_company_details_from_tmdb(params[:id])

    if company_data
      company = Company.find_or_create_by(company_id: company_data["id"]) do |c|
        c.company_name = company_data["name"]
        c.logo_path = company_data["logo_path"]
      end

      if company.persisted?
        redirect_to company_path(company), notice: "#{company.company_name} was added to your company list."
      else
        redirect_to search_companies_path, alert: "Failed to add the company."
      end
    else
      redirect_to search_companies_path, alert: "Company not found."
    end
  end

  private 


  #Search for companies on tmdb

  def search_companies_in_tmdb(query)
    url = URI("#{TMDB_API_URL}/search/company?api_key=#{TMDB_API_KEY}&query=#{CGI.escape(query)}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'

    response = http.request(request)
    search_results = JSON.parse(response.body)

    if search_results["results"]
      @search_results = search_results["results"]
    else
      @search_results = []
      Rails.logger.error "No companies found for query: #{query}"
    end
  end
  def fetch_company_details_from_tmdb(company_id)
    url = URI("#{TMDB_API_URL}/company/#{company_id}?api_key=#{TMDB_API_KEY}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'

    response = http.request(request)

    if response.code == "200"
      JSON.parse(response.body)
    else
      nil
    end
  end
 
  # Fetch the movies from the TMDB API for a given company ID
  def fetch_company_movies_from_api(company_id)
    @api_movies = []
    page = 1
    total_pages = 1  # Default value for the loop to start
# Loop through all pages of results
while page <= total_pages do
  url = URI("#{TMDB_API_URL}/discover/movie?with_companies=#{company_id}&api_key=#{TMDB_API_KEY}&page=#{page}")
  Rails.logger.info "Fetching page #{page} of movies from TMDB for company ID: #{company_id}"

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(url)
  request["accept"] = 'application/json'

  response = http.request(request)
  api_movies_data = JSON.parse(response.body)

  if response.code == "200" && api_movies_data["results"]
    @api_movies.concat(api_movies_data["results"])  # Append the results to the @api_movies array
    total_pages = api_movies_data["total_pages"]    # Update total pages from API response
    page += 1                                       # Move to the next page
  else
    Rails.logger.error "Error fetching movies: #{response.body}"
    break  # Exit the loop in case of an error
  end
end

Rails.logger.info "Fetched #{@api_movies.size} movies from TMDB for company ID: #{company_id}"
end

end 