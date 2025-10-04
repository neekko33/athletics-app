class CreateClasses < ActiveRecord::Migration[8.0]
  def change
    create_table :classes do |t|
      t.references :grade, null: false, foreign_key: true
      t.string :name
      t.integer :order

      t.timestamps
    end
  end
end
