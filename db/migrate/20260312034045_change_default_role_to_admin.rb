class ChangeDefaultRoleToAdmin < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :role, from: "timer", to: "admin"
  end
end
