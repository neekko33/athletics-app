class CreateLaneAthletes < ActiveRecord::Migration[8.0]
  def change
    create_table :lane_athletes do |t|
      t.references :lane, null: false, foreign_key: true
      t.references :athlete, null: false, foreign_key: true
      t.integer :relay_position

      t.timestamps
    end
  end
end
