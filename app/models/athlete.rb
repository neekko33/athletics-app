class Athlete < ApplicationRecord
  belongs_to :competition
  has_many :competition_events, through: :athlete_competition_events
  has_many :athlete_competition_events, dependent: :destroy
  has_many :events, through: :competition_events

  # 获取运动员选择的项目ID列表（用于表单回显）
  def event_ids
    events.pluck(:id)
  end
end
