class CompetitionEvent < ApplicationRecord
  belongs_to :competition
  belongs_to :event

  has_many :athlete_competition_events, dependent: :destroy
  has_many :athletes, through: :athlete_competition_events
  has_many :heats, dependent: :destroy
  has_many :lanes, through: :heats
  has_many :schedules, through: :heats
  has_many :competition_event_staff, dependent: :destroy
  has_many :staff, through: :competition_event_staff

  def field_event?
    event.event_type == "field"
  end

  def track_event?
    event.event_type == "track"
  end

  def relay?
    event.name.include?("接力")
  end
end
