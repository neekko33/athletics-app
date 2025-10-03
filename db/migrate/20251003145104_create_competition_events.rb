class CreateCompetitionEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :competition_events do |t|
      t.belongs_to :competition, null: false, foreign_key: true
      t.belongs_to :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
