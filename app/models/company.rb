class Company < ApplicationRecord
  has_many :production_companies
  has_many :movies, through: :production_companies
end
