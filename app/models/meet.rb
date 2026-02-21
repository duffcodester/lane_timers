class Meet < ApplicationRecord
  has_many :meet_sessions, dependent: :nullify

  validates :name, presence: true
end
