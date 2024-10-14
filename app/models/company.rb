class Company < ApplicationRecord
  has_many :production_companies, foreign_key: 'prodco_id'
  has_many :movies, through: :production_companies

  # Scope to fetch top companies
  scope :top_companies, -> { where(is_top_company: true) }
  
  self.primary_key = 'company_id'
end
