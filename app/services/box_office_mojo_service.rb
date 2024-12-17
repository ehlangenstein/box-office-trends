require 'nokogiri'
require 'open-uri'

class BoxOfficeMojoService
  BASE_URL = "https://www.boxofficemojo.com/title/"


  # Helper function to safely extract text
  def self.extract_text_or_nil(node)
    node ? node.text.strip : nil
  end

  # Helper function to safely clean and convert to integer
  def self.clean_money_text(money_text)
    money_text ? money_text.gsub(/[^\d]/, '').to_i : nil
  end

  def self.fetch_and_store_box_office_data(imdb_id)
    # Build the movie page URL using the IMDb ID
    url = "#{BASE_URL}#{imdb_id}/"
    #puts "Title URL: #{url}"
    
    begin
      # Fetch the title page
      title_page = Nokogiri::HTML(URI.open(url))

      # Extract the release code (e.g., 'rl2684977153')
      release_link = title_page.css('a[href*="/release/rl"]').first
      unless release_link
        #puts "no release link found for imdb id #{imdb_id}. skipping.."
        return nil 
      end

      release_code = release_link['href'].split('/')[2]
      #puts "Release code: #{release_code}"
      
      #if release_link
        #release_code = release_link['href'].split('/')[2]
        #puts "Release code: #{release_code}"
      #else
        #puts "No release link found for IMDb ID: #{imdb_id}"
        #exit
      #end

      # Construct the release page URL using the release code
      release_url = "https://www.boxofficemojo.com/release/#{release_code}/"
      #puts "Release URL: #{release_url}"
      release_page = Nokogiri::HTML(URI.open(release_url))

      # Extract Box Office data using .money class
      grosses_section = release_page.css('div.mojo-performance-summary-table')

      # Extract Domestic Box Office
      domestic_box_office = clean_money_text(grosses_section.at_xpath('.//span[contains(text(), "Domestic")]/ancestor::div[1]//span[@class="money"]')&.text)

      # Extract International Box Office (inside an <a> tag, followed by a nested span with class "money")
      international_box_office = clean_money_text(grosses_section.at_xpath('.//a[contains(text(), "International")]/parent::span/following-sibling::span/a/span[@class="money"]')&.text)
      if international_box_office.nil? # If the money span is directly inside the <a> tag
        international_box_office = clean_money_text(grosses_section.at_xpath('.//a[contains(text(), "International")]/span[@class="money"]')&.text)
      end

      # Extract Worldwide Box Office (same structure as International)
      worldwide_box_office = clean_money_text(grosses_section.at_xpath('.//a[contains(text(), "Worldwide")]/parent::span/following-sibling::span/a/span[@class="money"]')&.text)
      if worldwide_box_office.nil? # If the money span is directly inside the <a> tag
        worldwide_box_office = clean_money_text(grosses_section.at_xpath('.//a[contains(text(), "Worldwide")]/span[@class="money"]')&.text)
      end

      # Log extracted values before displaying
      #puts "Domestic Box Office: $#{domestic_box_office || 'N/A'}"
      #puts "International Box Office: $#{international_box_office || 'N/A'}"
      #puts "Worldwide Box Office: $#{worldwide_box_office || 'N/A'}"

      # Extract Distributor and Opening Weekend data
      distributor = release_page.at_xpath('.//span[contains(text(), "Distributor")]/following-sibling::span/text()').to_s.strip
      opening_weekend_box_office = clean_money_text(extract_text_or_nil(release_page.at_xpath('.//span[contains(text(), "Opening")]/following-sibling::span/span[@class="money"]')))

      # Corrected extraction logic for theaters, handling the comma correctly
      opening_theaters_text = release_page.at_xpath('.//span[contains(text(), "Opening")]/following-sibling::span')&.inner_html
      opening_theaters = opening_theaters_text[/(\d[\d,]*)\s+theaters/, 1].gsub(',', '').to_i if opening_theaters_text

      #puts "Distributor: #{distributor || 'N/A'}"
      #puts "Opening Weekend Box Office: $#{opening_weekend_box_office || 'N/A'}"
      #puts "Opening Theaters: #{opening_theaters || 'N/A'} theaters"

      # Extract Widest Release
      widest_release = clean_money_text(extract_text_or_nil(release_page.at_xpath('.//span[contains(text(), "Widest Release")]/following-sibling::span')))

      #puts "Widest Release: #{widest_release || 'N/A'} theaters"

      # Return a hash with the scraped box office data
      {
        domestic_box_office: domestic_box_office,
        international_box_office: international_box_office,
        worldwide_box_office: worldwide_box_office,
        distributor: distributor,
        opening_weekend_box_office: opening_weekend_box_office,
        opening_theaters: opening_theaters,
        widest_release: widest_release
      }
    rescue StandardError => e
      puts "Error fetching data for IMDb ID: #{imdb_id} - #{e.message}"
      return nil
    end 
  end
end 

  
    
