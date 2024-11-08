require 'net/http'
require 'json'

TMDB_API_URL = "https://api.themoviedb.org/3"
TMDB_API_KEY = "a34e8adae9ec536dc53c3c325e782801" # Replace with your actual TMDB API key

Company.where(logo_path: [nil, '']).each do |company|
  # Skip if company_id is nil
  next unless company.company_id

  url = URI("#{TMDB_API_URL}/company/#{company.company_id}?api_key=#{TMDB_API_KEY}")
  response = Net::HTTP.get_response(url)

  if response.is_a?(Net::HTTPSuccess)
    data = JSON.parse(response.body)
    company.update(logo_path: data['logo_path'])
    puts "Updated logo_path for #{company.company_name}"
  else
    puts "Failed to fetch logo for #{company.company_name}"
  end
end
