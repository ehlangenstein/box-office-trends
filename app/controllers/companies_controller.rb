class CompaniesController < ApplicationController

  require 'net/http'
  require 'json'

  TMDB_API_URL = "https://api.themoviedb.org/3"
  TMDB_API_KEY = "a34e8adae9ec536dc53c3c325e782801"


  # Top Companies Home Page
  def top_companies_home
    @top_companies = Company.top_companies
  end

  def index
    # Fetch only companies that are associated with movies in the logged_movies table
   @companies = Company.joins(:production_companies).distinct
  end

  def show
     # Find the company in the database
    @company = Company.find_by("company_id" => params["id"])
    Rails.logger.info "Checking if company #{@company&.company_id} is a top company..."

    # If the company isn't in the local database, fetch it from the TMDB API and add it to the local database
    if @company.nil?
       Rails.logger.info "Company not found in the database, fetching from TMDB..."
      
       company_data = fetch_company_details_from_tmdb(params[:id])

      if company_data
        Rails.logger.info "Company found on TMDB: #{company_data["name"]}"
        @company = OpenStruct.new(
          company_id: company_data["id"],
          company_name: company_data["name"],
          logo_path: company_data["logo_path"],
        )
        @movies = fetch_movies_from_tmdb(@company.company_id)
      else
        redirect_to companies_path, alert: "Company not found."
        Rails.logger.error "Company not found on TMDB for ID: #{params[:id]}"
      return
    end
    else
    # If the company is found in the local database, fetch associated movies
    @movies = fetch_movies_from_tmdb(@company.company_id) if @company
  end
    # Find the movies associated with the company in the logged movies table
    #@movies = Movie.joins(:production_companies).where(production_companies: { prodco_id: @company.company_id }) 
    
    # Check if the company is a top company by matching with TOP_COMPANY_IDS
    @is_top_company = @company.is_top_company
    Rails.logger.info "Is company #{@company.company_name} (ID #{@company.company_id}) a top company? #{@is_top_company}"
  
    if @is_top_company
      render 'top_show'
    else
      render 'show'
    end

  end 

  def search
    if params[:query].present?
      search_companies_in_tmdb(params[:query])
    end
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


  # Fetch movies associated with a company from TMDB
  def fetch_movies_from_tmdb(company_id)
      url = URI("#{TMDB_API_URL}/discover/movie?with_companies=#{company_id}&api_key=#{TMDB_API_KEY}&page=1")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request["accept"] = 'application/json'

      response = http.request(request)
      data = JSON.parse(response.body)

      if response.code == "200" && data["results"]
        Rails.logger.info "Fetched #{data['results'].size} movies for company ID #{company_id} (limited to first page)"
        data["results"] # Return only the first page of movies
      else
        Rails.logger.error "Failed to fetch movies for company ID #{company_id}: #{response.body}"
        []
      end

    
  end
end