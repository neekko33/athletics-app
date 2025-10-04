class RemoveCompetitionIdFromAthletes < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :athletes, :competitions
    remove_column :athletes, :competition_id, :integer
  end
end
