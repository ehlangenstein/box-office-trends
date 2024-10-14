require 'json'
require 'csv'

# Load and parse the JSON file
file_path = 'production_company_ids_10_08_2024.json'
json_data = JSON.parse(File.read(file_path))

# Create or open the CSV file for writing
CSV.open('production_companies.csv', 'w', headers: ['id', 'name'], write_headers: true) do |csv|
  json_data.each do |company|
    # Write each company id and name to the CSV file
    csv << [company['id'], company['name']]
  end
end

puts 'JSON data successfully converted to CSV and saved as production_companies.csv'
