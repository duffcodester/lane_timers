class AddNameToMeetSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :meet_sessions, :name, :string
  end
end
