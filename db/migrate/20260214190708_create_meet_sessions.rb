class CreateMeetSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :meet_sessions do |t|
      t.date :date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false

      t.timestamps
    end

    add_index :meet_sessions, :date, unique: true
  end
end
