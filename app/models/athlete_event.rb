class AthleteEvent < ApplicationRecord
  belongs_to :athlete, dependent: :destroy
  belongs_to :event, dependent: :destroy
end
