class User < ApplicationRecord
  has_secure_password
  has_many :user_sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
