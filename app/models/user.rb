class User < ApplicationRecord
  has_secure_password
  belongs_to :club, optional: true

  enum :role, { admin: "admin", timer: "timer", official: "official", manager: "manager", coach: "coach" }

  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only letters, numbers, and underscores" }
  validates :password, length: { minimum: 8 }, allow_nil: true

  before_save { self.username = username.downcase }
end
