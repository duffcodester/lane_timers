class Club < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :color, presence: true
  validates :abbreviation, length: { maximum: 12 }

  before_save :set_bookable

  private

  def set_bookable
    self.bookable = coach.present? && phone.present? && email.present? && address.present?
    true
  end
end
