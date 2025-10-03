class AddAvgTimeToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :avg_time, :integer, comment: "平均用时，单位为分钟"
  end

  def down
    remove_column :events, :avg_time
  end
end
