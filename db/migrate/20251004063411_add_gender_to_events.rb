class AddGenderToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :gender, :string
  end

  def down
    remove_column :events, :gender
  end
end
