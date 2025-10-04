class ChangeSchedulesToReferenceHeats < ActiveRecord::Migration[8.0]
  def change
    # 删除旧的外键和列
    remove_foreign_key :schedules, :competition_events if foreign_key_exists?(:schedules, :competition_events)
    remove_column :schedules, :competition_event_id, :bigint

    # 添加新的外键
    add_reference :schedules, :heat, null: false, foreign_key: true, default: 1

    # 移除默认值（只是为了让迁移能执行）
    change_column_default :schedules, :heat_id, from: 1, to: nil
  end
end
