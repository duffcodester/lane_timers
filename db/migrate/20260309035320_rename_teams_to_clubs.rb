class RenameTeamsToClubs < ActiveRecord::Migration[8.1]
  def change
    rename_table :teams, :clubs
    rename_column :bookings, :team_id, :club_id
  end
end
