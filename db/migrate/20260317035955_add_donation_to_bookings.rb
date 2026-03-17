class AddDonationToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :donation, :boolean, default: false
  end
end
