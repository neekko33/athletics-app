class Competition < ApplicationRecord
  has_many :competition_events, dependent: :destroy
  has_many :events, through: :competition_events
  has_many :grades, dependent: :destroy
  has_many :klasses, through: :grades
  has_many :athletes, through: :klasses
  has_many :staff, dependent: :destroy
  has_many :heats, through: :competition_events
  has_many :schedules, through: :heats

  validates :name, presence: true
  validates :start_date, presence: true
  validates :track_lanes, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 10 }
end
