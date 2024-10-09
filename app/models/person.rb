class Person < ApplicationRecord
  has_many :credits
  has_many :movies, through: :credits
end
