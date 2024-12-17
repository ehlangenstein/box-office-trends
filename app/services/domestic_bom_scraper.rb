# app/services/box_office_scraper.rb
# 
require 'nokogiri'
require 'open-uri'

class DomesticBomScraper
  BASE_MONTH_URL = "https://www.boxofficemojo.com/month"
  BASE_YEAR_URL = "https://www.boxofficemojo.com/year"
  BASE_WEEK_URL = "https://www.boxofficemojo.com/weekly"

  # Centralized scrape method that uses different scrape functions based on the type
  def self.scrape_data(type:, year:, month: nil, week_number: nil, release_scale: :all)
    case type
    when :weekly
      scrape_week(year, week_number)
    when :monthly
      scrape_month(year, month)
    when :yearly
      scrape_year(year, release_scale)
    else
      raise ArgumentError, "Invalid type: #{type}"
    end
  end

  # Map month numbers to their full names
  MONTH_NAMES = {
    1 => 'january',
    2 => 'february',
    3 => 'march',
    4 => 'april',
    5 => 'may',
    6 => 'june',
    7 => 'july',
    8 => 'august',
    9 => 'september',
    10 => 'october',
    11 => 'november',
    12 => 'december'
  }

  RELEASE_SCALES = {
    all: 'all',
    limited: 'limited',
    wide: 'wide'
  }

  #scrape weekly box office data 
  def self.scrape_week(year, week_number)
    # Format the week number with 'W' prefix as used in the URL (e.g., "2024W43")
    week_format = "#{year}W#{week_number.to_s.rjust(2, '0')}"
    url = "#{BASE_WEEK_URL}/#{week_format}/"
    
    Rails.logger.info "Scraping weekly data from URL: #{url}"
    doc = Nokogiri::HTML(URI.open(url))

    movies = []

    doc.css('table tr').each_with_index do |row, index|
      next if index == 0 # Skip the header row
      columns = row.css('td')

      # Extract the movie title and link
      title_link = columns[2].at_css('a')
      movie_title = title_link ? title_link.text.strip : 'N/A' # Use 'N/A' if title_link is nil
      movie_url = "https://www.boxofficemojo.com#{title_link['href']}" if title_link
      
      imdb_id = fetch_imdb_id_from_release_page(movie_url) if movie_url

      # If distributor is missing, fetch it from the release page
      distributor = columns[10].text.strip
      if distributor == "-" && movie_url
        distributor = fetch_distributor_from_release_page(movie_url)
      end

      movie = {
        rank: columns[0].text.strip,
        rank_last_week: columns[1].text.strip == '-' ? 0 : columns[1].text.strip.to_i,
        title: movie_title,
        imdb_id: imdb_id,
        weekly_gross: clean_currency(columns[3].text.strip),
        gross_change_per_week: clean_percentage(columns[4].text.strip), #percentage
        total_theaters: clean_integer(columns[5].text.strip),
        change_theaters_per_week: clean_currency(columns[6].text.strip),
        per_theater_average_gross: clean_currency(columns[7].text.strip),
        total_gross: clean_currency(columns[8].text.strip),
        weeks_in_release: columns[9].text.strip,
        distributor: distributor
      }

      movies << movie
    end

    movies
  end


  # Scrape monthly box office data with release type filter
  def self.scrape_month(year, month)
    # Get the full name of the month
    month=month.to_i
    month_name = MONTH_NAMES[month]
    raise ArgumentError, 'Invalid month' unless month_name

    # Build the correct URL
    url = "#{BASE_MONTH_URL}/#{month_name}/#{year}/?grossesOption=calendarGrosses"
    doc = Nokogiri::HTML(URI.open(url))

    movies = []

    # Modify this to match the HTML structure of Box Office Mojo's table
    doc.css('table tr').each_with_index do |row, index|
      next if index == 0 # Skip the header row
      columns = row.css('td')


      # Extract the movie title and link
      title_link = columns[1].at_css('a')
      movie_title = title_link.text.strip
      movie_url = "https://www.boxofficemojo.com#{title_link['href']}" if title_link

      imdb_id = fetch_imdb_id_from_release_page(movie_url) if movie_url

      # If distributor is missing, fetch it from the release page
      distributor = columns[9].text.strip
      if distributor == "-" && movie_url
       
        distributor = fetch_distributor_from_release_page(movie_url)
      end


      movie = {
        rank: columns[0].text.strip,
        title: columns[1].text.strip,
        imdb_id: imdb_id,
        domestic_gross: clean_currency(columns[5].text.strip),
        total_theaters: clean_integer(columns[6].text.strip),
        total_gross: clean_currency(columns[7].text.strip),
        release_date: parse_date(columns[8].text.strip),
        distributor: distributor
      }

      movies << movie
    end

    movies
  end

  # Scrape yearly box office data with release type filter
  #later need to pull data for only in month releases vs gross calendar - currently does calendar grosses 
  def self.scrape_year(year, release_scale = :all)
    release_scale=release_scale.to_sym
    scale_query = RELEASE_SCALES[release_scale]
    raise ArgumentError, 'Invalid release scale' unless scale_query

    url = "#{BASE_YEAR_URL}/#{year}/?grossesOption=totalGrosses&releaseScale=#{scale_query}"
    doc = Nokogiri::HTML(URI.open(url))

    movies = []

    doc.css('table tr').each_with_index do |row, index|
      next if index == 0 # Skip the header row
      columns = row.css('td')

      # Extract the movie title and link
      title_link = columns[1].at_css('a')
      movie_title = title_link.text.strip
      movie_url = "https://www.boxofficemojo.com#{title_link['href']}" if title_link

      imdb_id = fetch_imdb_id_from_release_page(movie_url) if movie_url

      # If distributor is missing, fetch it from the release page
      distributor = columns[12].text.strip
      if distributor == "-"  && movie_url
        distributor = fetch_distributor_from_release_page(movie_url)
      end

      movie = {
        rank: columns[0].text.strip,
        title: columns[1].text.strip,
        imdb_id: imdb_id,
        year: year,
        domestic_gross: clean_currency(columns[5].text.strip),
        total_theaters: clean_integer(columns[6].text.strip),
        opening_rev: clean_currency(columns[7].text.strip),
        percent_of_total: clean_percentage(columns[8].text.strip),
        open_wknd_theaters: clean_integer(columns[9].text.strip),
        opening_weekend: parse_date(columns[10].text.strip, year),
        distributor: distributor
      }

      movies << movie
    end

    movies
  end


  # Fetch distributor from a movie's release page
  def self.fetch_distributor_from_release_page(movie_url)
    begin
      release_page = Nokogiri::HTML(URI.open(movie_url))
      distributor_element = release_page.at_xpath('//span[contains(text(), "Distributor")]/following-sibling::span')
      
      if distributor_element
        distributor_text = distributor_element.inner_text.strip
        distributor_text
      else
        Rails.logger.warn "Distributor not found on release page: #{movie_url}"
        'N/A'
      end
    rescue OpenURI::HTTPError => e
      Rails.logger.error "Error fetching distributor from #{movie_url}: #{e.message}"
      'N/A'
    end
  end


  # Fetch IMDb ID from a movie's release page
  def self.fetch_imdb_id_from_release_page(movie_url)
    begin
      release_page = Nokogiri::HTML(URI.open(movie_url))
      imdb_link = release_page.at_css('a[href*="imdb.com/title"]')
      if imdb_link
        imdb_id = imdb_link['href'].match(/title\/(tt\d+)/)[1]  # Extract IMDb ID
        #Rails.logger.info "Fetched IMDb ID: #{imdb_id}"
        imdb_id
      else
        Rails.logger.warn "IMDb ID not found on release page: #{movie_url}"
        nil
      end
    rescue OpenURI::HTTPError => e
      Rails.logger.error "Error fetching IMDb ID from #{movie_url}: #{e.message}"
      nil
    end
  end

  # Helper method to clean and convert currency values into integers
  def self.clean_currency(value)
    value.gsub(/[$,]/, '').to_i
  end

   # Helper method to clean and convert values into integers
   def self.clean_integer(value)
    value.gsub(/[^\d]/, '').to_i
  end

  # Helper method to parse dates formatted as "Apr 15"
  def self.parse_date(value, year = nil)
    if value =~ /^\w{3} \d{1,2}$/ # Checks if format is "Jun 14"
      # If only month and day are present, add the provided year
      Date.strptime("#{value} #{year}", "%b %d %Y") rescue nil
    else
      Date.strptime(value, "%b %d, %Y") rescue nil # For full "Jun 14, 2023" format
    end
  end

  # Helper method to clean percentage values
  def self.clean_percentage(value)
    value.gsub('%', '').to_f / 100.0
  end


  # Method to save yearly data to the database
  def self.save_yearly_data(movies_data)
    movies_data.each do |movie_data|
      # Find the movie by IMDb ID to link to `movies` table, or create a new record
      movie = Movie.find_or_create_by(imdb_id: movie_data[:imdb_id])
      
      if movie
        additional_data = BoxOfficeMojoService.fetch_and_store_box_office_data(movie_data[:imdb_id])
        tmdb_data = TmdbMovieService.fetch_movie_by_imdb_id(movie_data[:imdb_id])

        # Update movie record with fetched TMDB data
        if tmdb_data
          movie.update(
            tmdb_id: tmdb_data[:tmdb_id],
            title: tmdb_data[:title],
            release_date: tmdb_data[:release_date],
            budget: tmdb_data[:budget],
            revenue: tmdb_data[:revenue],
            poster_path: tmdb_data[:poster_path]
          )
        end
        
        #Update with Box Office data - summary
        if additional_data
          movie.update(
            # New fields from BoxOfficeMojoService
            domestic_BO: additional_data[:domestic_box_office],
            intl_BO: additional_data[:international_box_office],
            total_BO: additional_data[:worldwide_box_office],
            distributor: additional_data[:distributor],
            open_wknd_BO: additional_data[:opening_weekend_box_office],
            open_wknd_theaters: additional_data[:opening_theaters],
            widest_release_theaters: additional_data[:widest_release]
          )
        end
        # Check if a record for this movie and year already exists
        yearly_record = YearlyBoxOffice.find_or_initialize_by(movie_id: movie.id, year: movie_data[:year])
         Rails.logger.debug "Saving yearly box office data for #{movie.title} (Year: #{movie_data[:year]})"
        yearly_record.update!(
          rank: movie_data[:rank],
          domestic_gross: movie_data[:domestic_gross],
          total_theaters: movie_data[:total_theaters],
          opening_rev: movie_data[:opening_rev],
          percent_of_total: movie_data[:percent_of_total],
          open_wknd_theaters: movie_data[:open_wknd_theaters],
          opening_weekend: movie_data[:opening_weekend],
          distributor: movie_data[:distributor]
        )
      else
        Rails.logger.warn "Movie with IMDb ID #{movie_data[:imdb_id]} not found. Skipping yearly data entry."
      end
    end
  end

  # Method to save weekly data to the database
  def self.save_weekly_data(movies_data, year, week_number)
    movies_data.each do |movie_data|
      movie = Movie.find_or_create_by(imdb_id: movie_data[:imdb_id])

      if movie
        additional_data = BoxOfficeMojoService.fetch_and_store_box_office_data(movie_data[:imdb_id])
        # Update movie record with TMDB data if necessary
        tmdb_data = TmdbMovieService.fetch_movie_by_imdb_id(movie_data[:imdb_id])
        if tmdb_data
          movie.update(
            tmdb_id: tmdb_data[:tmdb_id],
            title: tmdb_data[:title],
            release_date: tmdb_data[:release_date],
            budget: tmdb_data[:budget],
            revenue: tmdb_data[:revenue],
            poster_path: tmdb_data[:poster_path]
          )
        end

        #Update with Box Office data - summary
        if additional_data
          movie.update(
            # New fields from BoxOfficeMojoService
            domestic_BO: additional_data[:domestic_box_office],
            intl_BO: additional_data[:international_box_office],
            total_BO: additional_data[:worldwide_box_office],
            distributor: additional_data[:distributor],
            open_wknd_BO: additional_data[:opening_weekend_box_office],
            open_wknd_theaters: additional_data[:opening_theaters],
            widest_release_theaters: additional_data[:widest_release]
          )
        end

        # Save or update weekly box office data
        weekly_record = WeeklyBoxOffice.find_or_initialize_by(movie_id: movie.id, year: year, week_number: week_number)
        weekly_record.update!(
          rank: movie_data[:rank],
          weekly_gross: movie_data[:weekly_gross],
          total_theaters: movie_data[:total_theaters],
          change_theaters_per_week: movie_data[:change_theaters_per_week],
          per_theater_average_gross: movie_data[:per_theater_average_gross],
          total_gross: movie_data[:total_gross],
          weeks_in_release: movie_data[:weeks_in_release],
          distributor: movie_data[:distributor]
        )
      end
    end
  end

  # Method to save monthly data to the database
  def self.save_monthly_data(movies_data, year, month)
    movies_data.each do |movie_data|
      movie = Movie.find_or_create_by(imdb_id: movie_data[:imdb_id])

      if movie
        additional_data = BoxOfficeMojoService.fetch_and_store_box_office_data(movie_data[:imdb_id])
        # Update movie record with TMDB data if necessary
        tmdb_data = TmdbMovieService.fetch_movie_by_imdb_id(movie_data[:imdb_id])
        if tmdb_data
          movie.update(
            tmdb_id: tmdb_data[:tmdb_id],
            title: tmdb_data[:title],
            release_date: tmdb_data[:release_date],
            budget: tmdb_data[:budget],
            revenue: tmdb_data[:revenue],
            poster_path: tmdb_data[:poster_path]
          )
        end

        #Update with Box Office data - summary
        if additional_data
          movie.update(
            # New fields from BoxOfficeMojoService
            domestic_BO: additional_data[:domestic_box_office],
            intl_BO: additional_data[:international_box_office],
            total_BO: additional_data[:worldwide_box_office],
            distributor: additional_data[:distributor],
            open_wknd_BO: additional_data[:opening_weekend_box_office],
            open_wknd_theaters: additional_data[:opening_theaters],
            widest_release_theaters: additional_data[:widest_release]
          )
        end

        # Save or update monthly box office data
        monthly_record = MonthlyBoxOffice.find_or_initialize_by(movie_id: movie.id, year: year, month: month)
        monthly_record.update!(
          rank: movie_data[:rank],
          domestic_gross: movie_data[:domestic_gross],
          total_theaters: movie_data[:total_theaters],
          total_gross: movie_data[:total_gross],
          release_date: movie_data[:release_date],
          distributor: movie_data[:distributor]
        )
      end
    end
  end
end
