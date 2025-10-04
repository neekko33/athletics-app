class Athlete < ApplicationRecord
  belongs_to :klass
  has_one :grade, through: :klass
  has_one :competition, through: :grade

  has_many :lane_athletes, dependent: :destroy
  has_many :lanes, through: :lane_athletes
  has_many :heats, through: :lanes
  has_many :results, dependent: :destroy

  # 保留旧的关联用于过渡
  has_many :athlete_competition_events, dependent: :destroy
  has_many :competition_events, through: :athlete_competition_events
  has_many :events, through: :competition_events

  validates :name, presence: true
  validates :gender, presence: true, inclusion: { in: %w[男 女] }

  # 获取运动员选择的项目ID列表（用于表单回显）
  def event_ids
    events.pluck(:id)
  end

  def full_name
    "#{klass.full_name}#{name}"
  end
end
