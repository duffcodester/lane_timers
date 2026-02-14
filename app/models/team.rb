class Team < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :color, presence: true
  validates :abbreviation, length: { maximum: 5 }
end
