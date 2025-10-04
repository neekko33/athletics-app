class CompetitionEventStaff < ApplicationRecord
  belongs_to :competition_event
  belongs_to :staff

  validates :role_type, presence: true

  # 在特定比赛项目中的角色
  ROLE_TYPES = %w[chief_judge judge timer recorder starter announcer other].freeze

  validates :role_type, inclusion: { in: ROLE_TYPES }
end
