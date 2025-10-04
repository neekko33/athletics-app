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
  validates :end_date, presence: true
  validates :track_lanes, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 10 }
  validates :daily_start_time, :daily_end_time, presence: true
  validate :end_date_after_start_date

  def competition_dates
    return [] unless start_date && end_date
    (start_date..end_date).to_a
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "必须晚于或等于开始日期")
    end
  end
end
