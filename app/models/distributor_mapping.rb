class DistributorMapping < ApplicationRecord
  belongs_to :company, foreign_key: :company_id, primary_key: :company_id

  validates :distributor_name, presence: true, uniqueness: true
  validates :company_id, presence: true
end
