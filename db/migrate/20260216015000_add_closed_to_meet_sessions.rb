class AddClosedToMeetSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :meet_sessions, :closed, :boolean, default: false, null: false
  end
end
