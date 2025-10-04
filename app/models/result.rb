class Result < ApplicationRecord
  belongs_to :lane
  belongs_to :athlete

  validates :result_value, numericality: { greater_than: 0 }, allow_nil: true
  validates :rank, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :status, presence: true

  # 状态：pending(待录入), finished(已完成), disqualified(犯规)
  STATUS_TYPES = %w[pending finished disqualified].freeze

  validates :status, inclusion: { in: STATUS_TYPES }

  # 自动计算排名
  def self.calculate_ranks_for_heat(heat)
    results = Result.joins(lane: :heat)
                    .where(heats: { id: heat.id })
                    .where(status: "finished")
                    .order("result_value ASC")

    results.each_with_index do |result, index|
      result.update(rank: index + 1)
    end
  end
end
