class CreateGrades < ActiveRecord::Migration[8.0]
  def change
    create_table :grades do |t|
      t.references :competition, null: false, foreign_key: true
      t.string :name
      t.integer :order

      t.timestamps
    end
  end
end
