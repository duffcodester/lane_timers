class AddSubLaneToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :sub_lane, :string

    # Remove old unique index and add new one that includes sub_lane
    remove_index :bookings, [:lane, :date, :start_time]
    add_index :bookings, [:lane, :sub_lane, :date, :start_time], unique: true
  end
end
