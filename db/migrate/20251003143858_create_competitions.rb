class CreateCompetitions < ActiveRecord::Migration[8.0]
  def change
    create_table :competitions do |t|
      t.string :name
      t.date :start_date

      t.timestamps
    end
  end
end
