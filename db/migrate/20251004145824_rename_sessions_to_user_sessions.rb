class RenameSessionsToUserSessions < ActiveRecord::Migration[8.0]
  def change
    rename_table :sessions, :user_sessions
  end
end
