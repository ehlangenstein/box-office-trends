class TrendsController < ApplicationController
  def index
    # app/controllers/trends_controller.rb
    @yearly_box_offices = YearlyBoxOffice.all
    @movies = Movie.all

  end
end
