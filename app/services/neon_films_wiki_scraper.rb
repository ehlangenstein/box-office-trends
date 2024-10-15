require 'nokogiri'
require 'open-uri'
require 'net/http'

class NeonFilmsWikiScraper
  WIKIPEDIA_URL = 'https://en.wikipedia.org/wiki/List_of_Neon_films'
  WIKIDATA_API_URL = 'https://www.wikidata.org/w/api.php'

  def fetch_movies
    doc = Nokogiri::HTML(URI.open(WIKIPEDIA_URL))

    # Find the table with the list of films
    movies_table = doc.css('table.wikitable')

    movies = []

    # Loop through each row in the table
    movies_table.css('tr').each_with_index do |row, index|
      next if index == 0 # Skip the header row

      columns = row.css('td')

      # The first column (index 0) is the release date, which we skip
      movie_title = columns[1] ? columns[1].text.strip : 'No Title'  # Second column is the title

      # Query Wikidata for the movie's Wikidata ID
      wikidata_id = fetch_wikidata_id(movie_title)

      # Skip the movie if Wikidata ID is nil
      if wikidata_id
        movie = {
          title: movie_title,
          wikidata_id: wikidata_id  # Include the Wikidata ID if found
        }

        movies << movie
      else
        #Rails.logger.warn "Skipping movie: #{movie_title} as it doesn't have a Wikidata ID."
      end
    end

    movies
  end

  # Fetch the Wikidata ID for a movie using its title
  def fetch_wikidata_id(movie_title)
    uri = URI(WIKIDATA_API_URL)
    params = { action: 'wbsearchentities', search: movie_title, language: 'en', format: 'json', type: 'item' }
    uri.query = URI.encode_www_form(params)

    begin
      response = Net::HTTP.get(uri)
      result = JSON.parse(response)

      # Extract the first result's Wikidata ID, if any results are returned
      if result['search'] && result['search'][0]
        result['search'][0]['id']  # This is the Wikidata ID
      else
        nil
      end
    rescue StandardError => e
      Rails.logger.error "Error fetching Wikidata ID for #{movie_title}: #{e.message}"
      nil
    end
  end
end
