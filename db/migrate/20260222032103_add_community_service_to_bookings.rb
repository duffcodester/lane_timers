class AddCommunityServiceToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :community_service, :boolean, default: false, null: false
  end
end
