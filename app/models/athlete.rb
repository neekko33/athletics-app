class Athlete < ApplicationRecord
  belongs_to :competition
  has_many :events, through: :athlete_events
end
