class CreateAthletes < ActiveRecord::Migration[8.0]
  def change
    create_table :athletes do |t|
      t.string :name
      t.string :gender
      t.string :grade_name
      t.string :class_name

      t.timestamps
    end
  end
end
