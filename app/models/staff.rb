class Staff < ApplicationRecord
  belongs_to :competition
  has_many :competition_event_staff, dependent: :destroy
  has_many :competition_events, through: :competition_event_staff

  validates :name, presence: true
  validates :role, presence: true

  # 角色类型：judge(裁判), timer(计时员), recorder(记录员), coordinator(协调员), medical(医务), security(安保)
  ROLE_TYPES = %w[judge timer recorder coordinator medical security other].freeze

  validates :role, inclusion: { in: ROLE_TYPES }
end
