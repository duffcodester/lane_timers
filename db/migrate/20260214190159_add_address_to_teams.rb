class AddAddressToTeams < ActiveRecord::Migration[8.1]
  def change
    add_column :teams, :address, :string
  end
end
