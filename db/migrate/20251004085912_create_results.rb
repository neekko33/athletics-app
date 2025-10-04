class CreateResults < ActiveRecord::Migration[8.0]
  def change
    create_table :results do |t|
      t.references :lane, null: false, foreign_key: true
      t.references :athlete, null: false, foreign_key: true
      t.decimal :result_value, precision: 10, scale: 2 # 成绩值（秒或米）
      t.integer :rank # 名次
      t.string :status, default: 'pending' # pending, finished, disqualified
      t.text :notes # 备注（如犯规原因等）

      t.timestamps
    end

    add_index :results, [ :lane_id, :athlete_id ], unique: true
    add_index :results, :rank
  end
end
