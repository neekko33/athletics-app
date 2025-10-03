class Competition < ApplicationRecord
  has_many :events, through: :competition_events
  has_many :athletes, dependent: :destroy

  validates :name, presence: true
  validates :start_date, presence: true
end
