class WeeklyBoxOffice < ApplicationRecord
  # Associations
  belongs_to :movie
  belongs_to :company, foreign_key: :distributor, primary_key: :company_name, optional: true
  # Validations
  validates :week_number, :year, :movie_id, presence: true
  validates :rank, :rank_last_week, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 200 }, allow_nil: true
  validates :weekly_gross, :total_theaters, :change_theaters_per_week, :per_theater_average_gross, :total_gross, numericality: { only_integer: true }, allow_nil: true
  validates :gross_change_per_week, numericality: { greater_than_or_equal_to: -100, less_than_or_equal_to: 100 }, allow_nil: true

  # Scopes
  scope :by_week_and_year, ->(week, year) { where(week_number: week, year: year) }
  scope :top_ranked, ->(limit = 10) { order(rank: :asc).limit(limit) }
end
