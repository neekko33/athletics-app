class AddTrackLanesToCompetitions < ActiveRecord::Migration[8.0]
  def change
    add_column :competitions, :track_lanes, :integer, default: 8, null: false
  end
end
