class TrendsController < ApplicationController
  def index
    year = params[:year] || Date.today.year
    month = params[:month]
    week_number = params[:week]
    data_type = params[:type]&.to_sym || :yearly  # :weekly, :monthly, or :yearly
    
    @movies = DomesticBomScraper.scrape_data(
      type: data_type,
      year: year.to_i,
      month: month.to_i,
      week_number: week_number.to_s.rjust(2, '0').to_i
    )

    #Initialize weekly data collection if data type is weekly
    

    # Data Processing for Charts (for example, count movies by distributor)
    @movies_by_distributor = @movies.group_by { |movie| movie[:distributor] }
                    .transform_values(&:count)
  end
end
