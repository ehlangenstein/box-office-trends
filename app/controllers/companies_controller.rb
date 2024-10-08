class CompaniesController < ApplicationController
  def index
    @companies = Company.all
  end
  def show
    @company = Company.find_by("company_id" => params["id"])
    @movies = Movie.joins(:production_companies).where(production_companies: { prodco_id: @company.company_id }) 
  end 
end 