class AddCompetitionIdToAthletes < ActiveRecord::Migration[8.0]
  def change
    add_reference :athletes, :competition, null: false, foreign_key: true
  end

  def down
    remove_reference :athletes, :competition, foreign_key: true
  end
end
