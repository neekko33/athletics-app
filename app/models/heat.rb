class Heat < ApplicationRecord
  belongs_to :competition_event
  belongs_to :grade, optional: true # 径赛不需要年级
  has_many :lanes, dependent: :destroy
  has_many :athletes, through: :lanes
  has_one :schedule, dependent: :destroy

  validates :heat_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :total_lanes, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 10 }

  # 田赛项目需要年级
  validates :grade_id, presence: true, if: :field_event?

  def field_event?
    competition_event.event.event_type == "field"
  end

  def track_event?
    competition_event.event.event_type == "track"
  end

  def name
    if field_event?
      "#{grade.name} - 第#{heat_number}组"
    else
      "第#{heat_number}组"
    end
  end
end
