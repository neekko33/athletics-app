class Schedule < ApplicationRecord
  belongs_to :competition_event

  validates :scheduled_at, presence: true
  validates :venue, presence: true
  validates :status, presence: true

  # 状态：pending(待进行), in_progress(进行中), completed(已完成), cancelled(已取消)
  STATUS_TYPES = %w[pending in_progress completed cancelled].freeze

  validates :status, inclusion: { in: STATUS_TYPES }

  # 计算结束时间
  def calculate_end_at
    return unless scheduled_at && duration
    self.end_at = scheduled_at + duration.minutes
  end

  before_save :calculate_end_at

  # 检查时间冲突
  def self.conflicts_with?(scheduled_at, duration, venue, exclude_id = nil)
    end_at = scheduled_at + duration.minutes
    query = where(venue: venue)
              .where.not(status: "cancelled")
              .where("scheduled_at < ? AND end_at > ?", end_at, scheduled_at)

    query = query.where.not(id: exclude_id) if exclude_id
    query.exists?
  end

  def conflicting?
    return false unless scheduled_at && duration && venue
    Schedule.conflicts_with?(scheduled_at, duration, venue, id)
  end
end
