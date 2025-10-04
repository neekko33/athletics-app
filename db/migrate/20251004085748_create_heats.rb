class CreateHeats < ActiveRecord::Migration[8.0]
  def change
    create_table :heats do |t|
      t.references :competition_event, null: false, foreign_key: true
      t.references :grade, null: false, foreign_key: true
      t.integer :heat_number

      t.timestamps
    end
  end
end
