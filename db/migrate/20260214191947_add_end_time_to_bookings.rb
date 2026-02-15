class AddEndTimeToBookings < ActiveRecord::Migration[8.0]
  def up
    add_column :bookings, :end_time, :time

    # Backfill existing bookings: end_time = start_time + 60 minutes
    execute <<-SQL
      UPDATE bookings SET end_time = start_time + INTERVAL '60 minutes'
    SQL

    change_column_null :bookings, :end_time, false
  end

  def down
    remove_column :bookings, :end_time
  end
end
