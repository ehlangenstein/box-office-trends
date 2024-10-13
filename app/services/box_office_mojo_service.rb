require 'nokogiri'
require 'open-uri'

class BoxOfficeMojoService
  BASE_URL = "https://www.boxofficemojo.com/title/"

  def self.fetch_and_store_box_office_data(imdb_id)
    # Build the movie page URL using the IMDb ID
    url = "#{BASE_URL}#{imdb_id}/"
    
    # Fetch and parse the page
    movie_page = Nokogiri::HTML(URI.open(url))

    # Find the `rl` code for the weekend box office page
    rl_code = movie_page.at_css('a[href*="weekend"]')['href'].match(/release\/(rl\d+)\//)[1]

    # Build the release page URL
    release_url = "https://www.boxofficemojo.com/release/#{rl_code}/"
    
    # Fetch and parse the release page
    release_page = Nokogiri::HTML(URI.open(release_url))

    # Extract the box office data
    domestic_box_office = release_page.at_css('div.mojo-performance-summary-table span.money').text.strip.gsub(/[^\d]/, '').to_i
    international_box_office = release_page.css('div.mojo-performance-summary-table').at_xpath('.//span[contains(text(), "International")]/following-sibling::span').text.strip.gsub(/[^\d]/, '').to_i
    worldwide_box_office = release_page.css('div.mojo-performance-summary-table').at_xpath('.//span[contains(text(), "Worldwide")]/following-sibling::span').text.strip.gsub(/[^\d]/, '').to_i
    opening_weekend_box_office = release_page.at_xpath('//span[contains(text(), "Opening")]/following-sibling::span').text.strip.gsub(/[^\d]/, '').to_i
    theaters_count = release_page.at_xpath('//span[contains(text(), "Opening")]/following-sibling::br/following-sibling::span').text.strip.to_i

    # Log the fetched data for verification
    Rails.logger.info "Fetched Box Office Data for IMDb ID: #{imdb_id}"
    Rails.logger.info "Domestic: #{domestic_box_office}, International: #{international_box_office}, Worldwide: #{worldwide_box_office}, Opening Weekend: #{opening_weekend_box_office}, Theaters Count: #{theaters_count}"

    # Find or create the BoxOffice record in the database
    box_office = BoxOffice.find_or_initialize_by(imdb_id: imdb_id)
    box_office.update(
      domestic_box_office: domestic_box_office,
      international_box_office: international_box_office,
      total_box_office: worldwide_box_office,
      opening_weekend_box_office: opening_weekend_box_office,
      theaters_count: theaters_count
    )
  end
end