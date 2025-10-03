class Event < ApplicationRecord
  has_many :competitions, through: :competition_events
end
