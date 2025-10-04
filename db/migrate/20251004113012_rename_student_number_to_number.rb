class RenameStudentNumberToNumber < ActiveRecord::Migration[8.0]
  def change
    rename_column :athletes, :student_number, :number
  end
end
