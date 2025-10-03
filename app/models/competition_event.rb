class CompetitionEvent < ApplicationRecord
  belongs_to :competition
  belongs_to :event
  has_many :athletes, through: :athlete_competition_events
  has_many :athlete_competition_events, dependent: :destroy
end
