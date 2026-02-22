class AddNotesToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :notes, :text
  end
end
