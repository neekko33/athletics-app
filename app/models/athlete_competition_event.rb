class AthleteCompetitionEvent < ApplicationRecord
  belongs_to :athlete
  belongs_to :competition_event
end
