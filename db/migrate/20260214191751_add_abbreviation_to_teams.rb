class AddAbbreviationToTeams < ActiveRecord::Migration[8.1]
  def change
    add_column :teams, :abbreviation, :string
  end
end
