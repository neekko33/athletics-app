class CreateSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :schedules do |t|
      t.references :competition_event, null: false, foreign_key: true
      t.datetime :scheduled_at
      t.datetime :end_at
      t.string :venue
      t.integer :duration # 预计时长（分钟）
      t.string :status, default: 'pending' # pending, in_progress, completed, cancelled
      t.text :notes # 备注
      t.integer :display_order # 显示顺序

      t.timestamps
    end

    add_index :schedules, :scheduled_at
    add_index :schedules, :status
  end
end
