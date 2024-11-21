class YearlyBoxOffice < ApplicationRecord
  # Associations
  belongs_to :movie  # Assumes each yearly box office record is linked to a movie
  belongs_to :company, foreign_key: :company_id, primary_key: :company_id, optional: true

  # Validations
  validates :year, presence: true
  validates :movie_id, presence: true
  validates :rank, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 200 }, allow_nil: true
  validates :domestic_gross, :total_theaters, :opening_rev, :open_wknd_theaters, numericality: { only_integer: true }, allow_nil: true
  validates :percent_of_total, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  # Scopes
  scope :by_year, ->(year) { where(year: year) }
  scope :top_ranked, ->(limit = 10) { order(rank: :asc).limit(limit) }
  scope :high_grossing, ->(threshold) { where("domestic_gross >= ?", threshold) }
  scope :top_ranked_in_year, ->(year, limit = 10) { by_year(year).order(rank: :asc).limit(limit) }

end
