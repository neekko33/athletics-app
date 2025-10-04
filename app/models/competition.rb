class Competition < ApplicationRecord
  has_many :competition_events, dependent: :destroy
  has_many :events, through: :competition_events
  has_many :grades, dependent: :destroy
  has_many :klasses, through: :grades
  has_many :athletes, through: :klasses
  has_many :staff, dependent: :destroy

  validates :name, presence: true
  validates :start_date, presence: true
end
