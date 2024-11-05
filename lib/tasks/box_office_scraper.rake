# lib/tasks/box_office_scraper.rake
namespace :box_office do
  desc "Scrape and save yearly box office data from 2000 to the current year"
  task scrape_yearly_data: :environment do
    start_year = 2000
    current_year = Time.now.year

    (start_year..current_year).each do |year|
      Rails.logger.info "Scraping box office data for year #{year}"
      DomesticBomScraper.scrape_data(type: :yearly, year: year)
    end

    Rails.logger.info "Finished scraping box office data from #{start_year} to #{current_year}"
  end
end
