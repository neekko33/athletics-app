class Event < ApplicationRecord
  has_many :competitions, through: :competition_events
  has_many :athletes, through: :athlete_events
end
