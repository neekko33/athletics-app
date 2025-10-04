class Schedule < ApplicationRecord
  belongs_to :heat

  validates :scheduled_at, presence: true

  # 虚拟属性用于表单
  attr_accessor :scheduled_date, :scheduled_time

  # 状态：pending(待进行), in_progress(进行中), completed(已完成), cancelled(已取消)
  STATUS_TYPES = %w[pending in_progress completed cancelled].freeze

  validates :status, inclusion: { in: STATUS_TYPES }, if: -> { status.present? }

  # 检查时间冲突
  def self.conflicts_with?(scheduled_at, duration, venue, exclude_id = nil)
    return false unless scheduled_at && duration && venue

    end_at = scheduled_at + duration.minutes
    query = where(venue: venue)
              .where.not(status: "cancelled")
              .where("scheduled_at < ? AND end_at > ?", end_at, scheduled_at)

    query = query.where.not(id: exclude_id) if exclude_id
    query.exists?
  end

  def conflicting?
    return false unless scheduled_at && end_at && venue

    Schedule.where(venue: venue)
            .where.not(status: "cancelled")
            .where.not(id: id)
            .where("scheduled_at < ? AND end_at > ?", end_at, scheduled_at)
            .exists?
  end
end
