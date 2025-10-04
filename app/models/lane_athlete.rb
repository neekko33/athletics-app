class LaneAthlete < ApplicationRecord
  belongs_to :lane
  belongs_to :athlete

  # relay_position: 接力项目中的棒次（1-4），非接力项目为nil
  validates :relay_position, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 4 }, allow_nil: true

  # 确保同一lane中同一athlete不重复
  validates :athlete_id, uniqueness: { scope: :lane_id }

  # 接力项目中，确保同一lane的棒次不重复
  validates :relay_position, uniqueness: { scope: :lane_id }, if: :relay_position?

  default_scope { order(relay_position: :asc) }
end
