class TrendsController < ApplicationController
  def index
    # app/controllers/trends_controller.rb
    @yearly_box_offices = YearlyBoxOffice.all
    @movies = Movie.all
    @monthly_box_offices = MonthlyBoxOffice.all
    @weekly_box_offices = WeeklyBoxOffice.all
  end
end
