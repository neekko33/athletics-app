class CompetitionEvent < ApplicationRecord
  belongs_to :competition
  belongs_to :event
end
