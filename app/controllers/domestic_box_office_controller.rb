# app/controllers/domestic_box_office_controller.rb
class DomesticBoxOfficeController < ApplicationController
  def index
    #Filter type - Monthly or Yearly
    @filter_type = params[:filter_type] || 'monthly'
    @year = params[:year] || Date.today.year 
    
    #Initialize movies as an empty array 
    @movies = []

    if @filter_type == 'monthly'
      @month = params[:month].to_i.zero? ? Date.today.month : params[:month].to_i
      
      # Scrape the data for the selected month and year
      @movies = DomesticBomScraper.scrape_month(@year, @month)
    elsif @filter_type == 'yearly'
       @release_scale = params[:release_scale] || 'all'
       @movies = DomesticBomScraper.scrape_year(@year.to_i, @release_scale.to_sym)
    end
  end 

  def filter
    @filter_type = params[:filter_type] || 'monthly'

    if @filter_type == 'monthly'
      redirect_to domestic_box_office_index_path(year: params[:year], month: params[:month])
    elsif @filter_type == 'yearly'
      redirect_to domestic_box_office_index_path(year: params[:year], release_scale: params[:release_scale], filter_type: @filter_type)
    end
  end
end
