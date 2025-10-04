class CreateLanes < ActiveRecord::Migration[8.0]
  def change
    create_table :lanes do |t|
      t.references :heat, null: false, foreign_key: true
      t.integer :lane_number
      t.integer :position

      t.timestamps
    end
  end
end
