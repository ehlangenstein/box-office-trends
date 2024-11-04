# app/services/box_office_scraper.rb
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

      # If distributor is missing, fetch it from the release page
      distributor = columns[10].text.strip
      if distributor == "-" && movie_url
        Rails.logger.info "Distributor is missing ('-') for '#{movie_title}'. Fetching from release page: #{movie_url}"
        distributor = fetch_distributor_from_release_page(movie_url)
      end

      movie = {
        rank: columns[0].text.strip,
        rank_last_week: columns[1].text.strip == '-' ? 0 : columns[1].text.strip.to_i,
        title: movie_title,
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

      # If distributor is missing, fetch it from the release page
      distributor = columns[9].text.strip
      if distributor == "-" && movie_url
        Rails.logger.info "Distributor is missing ('-') for '#{movie_title}'. Using release page URL: #{movie_url}"
        distributor = fetch_distributor_from_release_page(movie_url)
      end


      movie = {
        rank: columns[0].text.strip,
        title: columns[1].text.strip,
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

  #later need to pull data for only in month releases vs gross calendar
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

      # If distributor is missing, fetch it from the release page
      distributor = columns[12].text.strip
      if distributor == "-"  && movie_url
        Rails.logger.info "Distributor is missing ('-') for '#{movie_title}'. Fetching from release page: #{movie_url}"
        distributor = fetch_distributor_from_release_page(movie_url)
      end

      movie = {
        rank: columns[0].text.strip,
        title: columns[1].text.strip,
        domestic_gross: clean_currency(columns[5].text.strip),
        total_theaters: clean_integer(columns[6].text.strip),
        opening_rev: clean_currency(columns[7].text.strip),
        percent_of_total: clean_percentage(columns[8].text.strip),
        open_wknd_theaters: clean_integer(columns[9].text.strip),
        opening_weekend: parse_date(columns[10].text.strip),
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
        Rails.logger.info "Fetched distributor: #{distributor_text}"
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


  # Helper method to clean and convert currency values into integers
  def self.clean_currency(value)
    value.gsub(/[$,]/, '').to_i
  end

   # Helper method to clean and convert values into integers
   def self.clean_integer(value)
    value.gsub(/[^\d]/, '').to_i
  end

  # Helper method to parse dates formatted as "Apr 15"
  def self.parse_date(value)
    Date.strptime(value, "%b %d") rescue nil
  end

  # Helper method to clean percentage values
  def self.clean_percentage(value)
    value.gsub('%', '').to_f / 100.0
  end

end
