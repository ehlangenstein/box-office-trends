class ApplicationController < ActionController::Base
  before_action :current_user
  before_action :set_top_companies

  def current_user
    @current_user = User.find_by({ "id" => session["user_id"] })
  end

  private

  def set_top_companies
    top_company_ids = [7, 41077, 14] # Replace with actual company IDs you want to track
    @top_companies = Company.where(id: top_company_ids)
  end

end