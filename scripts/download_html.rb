require 'net/http'
require 'uri'

url = URI.parse('https://www.boxofficemojo.com/release/rl2684977153/')
response = Net::HTTP.get_response(url)

if response.is_a?(Net::HTTPSuccess)
  html_content = response.body
  puts html_content
  # Optionally, save the content to an HTML file
  File.open("downloaded_page.html", "w") do |file|
    file.write(html_content)
  end
  puts "HTML content saved to downloaded_page.html"
else
  puts "Failed to retrieve the page. Error: #{response.code}"
end
