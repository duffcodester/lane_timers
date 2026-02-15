class RemoveUniqueIndexOnMeetSessionDate < ActiveRecord::Migration[8.0]
  def change
    remove_index :meet_sessions, :date
    add_index :meet_sessions, :date
  end
end
