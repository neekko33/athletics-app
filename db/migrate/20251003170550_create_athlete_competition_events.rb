class CreateAthleteCompetitionEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :athlete_competition_events do |t|
      t.belongs_to :athlete, null: false, foreign_key: true
      t.belongs_to :competition_event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
