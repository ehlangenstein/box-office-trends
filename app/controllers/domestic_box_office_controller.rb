# app/controllers/domestic_box_office_controller.rb
class DomesticBoxOfficeController < ApplicationController
  def index
    #Filter type - Monthly or Yearly
    filter_type = params[:filter_type] || 'Monthly'
    @year = params[:year] || Date.today.year 

    if filter_type == 'monthly'
      @month = params[:month].to_i.zero? ? Date.today.month : params[:month].to_i
      
      # Scrape the data for the selected month and year
      @movies = DomesticBOMScraper.scrape_month(@year, @month)
    # Default to current month and year if no filter is applied
    @year = params[:year] || Date.today.year
    @month = params[:month].to_i.zero? ? Date.today.month : params[:month].to_i
    @release_scale = params[:release_scale] || 'all'
    # Scrape the data for the selected month and year
    @movies = DomesticBOMScraper.scrape_month(@year, @month)
  end

  def filter
    redirect_to domestic_box_office_index_path(year: params[:year], month: params[:month])
  end
end
