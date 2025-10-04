class CreateCompetitionEventStaff < ActiveRecord::Migration[8.0]
  def change
    create_table :competition_event_staffs do |t|
      t.references :competition_event, null: false, foreign_key: true
      t.references :staff, null: false, foreign_key: true
      t.string :role_type

      t.timestamps
    end
  end
end
