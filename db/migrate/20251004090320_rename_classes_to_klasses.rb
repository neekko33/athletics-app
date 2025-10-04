class RenameClassesToKlasses < ActiveRecord::Migration[8.0]
  def change
    rename_table :classes, :klasses
    rename_column :athletes, :class_id, :klass_id
  end
end
