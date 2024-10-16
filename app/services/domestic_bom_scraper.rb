# app/services/box_office_scraper.rb
require 'nokogiri'
require 'open-uri'

class DomesticBomScraper
  BASE_MONTH_URL = "https://www.boxofficemojo.com/month"
  BASE_YEAR_URL = "https://www.boxofficemojo.com/year"

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

  def self.scrape_month(year, month)
    # Get the full name of the month
    month=month.to_i
    month_name = MONTH_NAMES[month]
    raise ArgumentError, 'Invalid month' unless month_name

    # Build the correct URL
    url = "#{BASE_URL}/#{month_name}/#{year}/?grossesOption=calendarGrosses"
    doc = Nokogiri::HTML(URI.open(url))

    movies = []

    # Modify this to match the HTML structure of Box Office Mojo's table
    doc.css('table tr').each_with_index do |row, index|
      next if index == 0 # Skip the header row
      columns = row.css('td')

      movie = {
        rank: columns[0].text.strip,
        title: columns[1].text.strip,
        domestic_gross: clean_currency(columns[5].text.strip),
        total_theaters: clean_integer(columns[6].text.strip),
        total_gross: clean_currency(columns[7].text.strip),
        release_date: parse_date(columns[8].text.strip),
        distributor: columns[9].text.strip
      }

      movies << movie
    end

    movies
  end

  # Scrape yearly box office data with release type filter
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

      movie = {
        rank: columns[0].text.strip,
        title: columns[1].text.strip,
        domestic_gross: clean_currency(columns[5].text.strip),
        total_theaters: clean_integer(columns[6].text.strip),
        opening_rev: clean_currency(columns[7].text.strip),
        percent_of_total: clean_percentage(columns[8].text.strip),
        open_wknd_theaters: clean_integer(columns[9].text.strip),
        opening_weekend: parse_date(columns[10].text.strip),
        distributor: columns[12].text.strip
      }

      movies << movie
    end

    movies
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
