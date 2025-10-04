class Lane < ApplicationRecord
  belongs_to :heat
  has_many :lane_athletes, dependent: :destroy
  has_many :athletes, through: :lane_athletes
  has_many :results, dependent: :destroy

  validates :lane_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # 确保同一heat中不重复lane_number
  validates :lane_number, uniqueness: { scope: :heat_id }

  default_scope { order(lane_number: :asc) }

  # 是否是接力项目
  def relay?
    heat.competition_event.event.name.include?("接力")
  end

  # 接力项目需要4个运动员
  def valid_relay_team?
    return true unless relay?
    lane_athletes.count == 4
  end
end
