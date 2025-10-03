class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :name
      t.string :event_type
      t.integer :max_participants

      t.timestamps
    end
  end
end
