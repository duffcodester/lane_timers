class AddNameAndPhoneToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :name, :string
    add_column :bookings, :phone, :string
  end
end
