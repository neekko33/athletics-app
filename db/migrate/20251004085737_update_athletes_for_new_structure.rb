class UpdateAthletesForNewStructure < ActiveRecord::Migration[8.0]
  def change
    # 移除旧的字符串字段
    remove_column :athletes, :grade_name, :string
    remove_column :athletes, :class_name, :string

    # 添加对班级的引用，暂时允许为空
    add_reference :athletes, :class, null: true, foreign_key: true

    # 添加学号字段
    add_column :athletes, :student_number, :string
    add_index :athletes, :student_number
  end
end
