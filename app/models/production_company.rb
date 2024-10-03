class ProductionCompany < ApplicationRecord
  #join table to connect movies to production companies 
  belongs_to :movie
  belongs_to :company, foreign_key: 'prodco_id'
end
