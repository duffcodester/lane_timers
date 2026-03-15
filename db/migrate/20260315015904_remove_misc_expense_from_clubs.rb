class RemoveMiscExpenseFromClubs < ActiveRecord::Migration[8.1]
  def change
    remove_column :clubs, :misc_expense, :decimal, precision: 10, scale: 2, default: "0.0"
  end
end
