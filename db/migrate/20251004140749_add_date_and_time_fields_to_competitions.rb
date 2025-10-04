class AddDateAndTimeFieldsToCompetitions < ActiveRecord::Migration[8.0]
  def change
    add_column :competitions, :end_date, :date
    add_column :competitions, :daily_start_time, :string, default: "08:30"
    add_column :competitions, :daily_end_time, :string, default: "17:30"
  end
end
