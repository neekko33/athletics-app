class AddTotalLanesToHeats < ActiveRecord::Migration[8.0]
  def change
    add_column :heats, :total_lanes, :integer, default: 8, null: false
  end
end
