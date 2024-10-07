class Company < ApplicationRecord
  has_many :production_companies, foreign_key: 'prodco_id'
  has_many :movies, through: :production_companies
end
