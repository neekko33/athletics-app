class Athlete < ApplicationRecord
  belongs_to :competition
  has_many :competition_events, through: :athlete_competition_events
  has_many :athlete_competition_events, dependent: :destroy
end
