class Team < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :color, presence: true
end
