class AddMeetIdToMeetSessions < ActiveRecord::Migration[8.1]
  def change
    add_reference :meet_sessions, :meet, null: true, foreign_key: true
  end
end
