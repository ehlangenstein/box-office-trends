class MonthlyBoxOffice < ApplicationRecord
  # Associations
  belongs_to :movie
  belongs_to :company, foreign_key: :company_id, primary_key: :company_id, optional: true

  # Validations
  validates :month, :year, :movie_id, presence: true
  validates :rank, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 200 }, allow_nil: true
  validates :domestic_gross, :total_theaters, :total_gross, numericality: { only_integer: true }, allow_nil: true

  # Scopes
  scope :by_month_and_year, ->(month, year) { where(month: month, year: year) }
  scope :top_ranked, ->(limit = 10) { order(rank: :asc).limit(limit) }
end
