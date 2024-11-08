# lib/tasks/box_office_scraper.rake 
#alread ran this task to get historical data, so wont need to run this again - takes about an hour 
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

namespace :box_office do
  desc "Scrape and save weekly box office data from 2010 to the current year"
  task scrape_weekly_data: :environment do
    start_year = 2010
    current_year = Time.now.year
    
    (start_year..current_year).each do |year|
      (1..52).each do |week_number|
        Rails.logger.info "Scraping weekly box office data for year #{year}, week #{week_number}"
        movies_data = DomesticBomScraper.scrape_data(type: :weekly, year: year, week_number: week_number)
        DomesticBomScraper.save_weekly_data(movies_data, year, week_number)
      end
    end

    Rails.logger.info "Finished scraping weekly box office data from #{start_year} to #{current_year}"
  end
end

namespace :box_office do
  desc "Scrape and save monthly box office data from 2010 to the current year"
  task scrape_monthly_data: :environment do
    start_year = 2015
    #current_year = Time.now.year
    current_year = 2022
    (start_year..current_year).each do |year|
      (1..12).each do |month|
        Rails.logger.info "Scraping monthly box office data for year #{year}, month #{month}"
        movies_data = DomesticBomScraper.scrape_data(type: :monthly, year: year, month: month)
        DomesticBomScraper.save_monthly_data(movies_data, year, month)
      end
    end

    Rails.logger.info "Finished scraping monthly box office data from #{start_year} to #{current_year}"
  end
end


# lib/tasks/box_office_scraper.rake
#this is now the task that will update the current year data 
namespace :box_office do
  desc "Scrape and update yearly box office data for the current year"
  task update_current_year_data: :environment do
    current_year = Time.now.year

    Rails.logger.info "Updating box office data for the current year: #{current_year}"
    DomesticBomScraper.scrape_data(type: :yearly, year: current_year)

    Rails.logger.info "Finished updating box office data for #{current_year}"
  end
end

