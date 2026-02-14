class Team < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :color, presence: true
  validate :max_teams_limit, on: :create

  private

  def max_teams_limit
    if Team.count >= 10
      errors.add(:base, "Maximum of 10 teams allowed")
    end
  end
end
