class Grade < ApplicationRecord
  belongs_to :competition
  has_many :klasses, dependent: :destroy
  has_many :athletes, through: :klasses
  has_many :heats, dependent: :destroy

  validates :name, presence: true
  validates :order, presence: true, numericality: { only_integer: true }

  default_scope { order(order: :asc) }
end
