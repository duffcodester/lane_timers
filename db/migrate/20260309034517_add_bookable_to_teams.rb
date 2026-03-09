class AddBookableToTeams < ActiveRecord::Migration[8.1]
  def change
    add_column :teams, :bookable, :boolean, default: false, null: false
  end
end
