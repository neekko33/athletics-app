class CreateStaff < ActiveRecord::Migration[8.0]
  def change
    create_table :staffs do |t|
      t.references :competition, null: false, foreign_key: true
      t.string :name
      t.string :role
      t.string :contact

      t.timestamps
    end
  end
end
