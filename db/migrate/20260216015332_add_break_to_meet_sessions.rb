class AddBreakToMeetSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :meet_sessions, :break_period, :boolean, default: false, null: false
  end
end
