class Klass < ApplicationRecord
  belongs_to :grade
  has_many :athletes, dependent: :destroy

  validates :name, presence: true
  validates :order, presence: true, numericality: { only_integer: true }

  default_scope { order(order: :asc) }

  def full_name
    "#{grade.name}#{name}"
  end
end
