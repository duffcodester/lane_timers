class AddCoachToTeams < ActiveRecord::Migration[8.1]
  def change
    add_column :teams, :coach, :string
  end
end
