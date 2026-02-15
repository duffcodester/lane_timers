class AddMiscExpenseToTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :misc_expense, :decimal, precision: 10, scale: 2, default: 0
  end
end
