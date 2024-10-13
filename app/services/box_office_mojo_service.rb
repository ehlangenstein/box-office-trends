require 'nokogiri'
require 'open-uri'

class BoxOfficeMojoService
  BASE_URL = "https://www.boxofficemojo.com"

  def initialize(imdb_id)
    @imdb_id = imdb_id
  end

  def fetch_box_office_data
    movie_url = "#{BASE_URL}/title/#{@imdb_id}/"
    doc = Nokogiri::HTML(URI.open(movie_url))

    # Extract box office data - modify this based on what you inspect on Box Office Mojo
    domestic_gross = doc.css('.a-section .domestic .mojo-performance-summary-table').text.strip
    international_gross = doc.css('.a-section .international .mojo-performance-summary-table').text.strip
    total_gross = doc.css('.a-section .total .mojo-performance-summary-table').text.strip

    { 
      domestic_gross: domestic_gross,
      international_gross: international_gross,
      total_gross: total_gross
    }
  end
end
