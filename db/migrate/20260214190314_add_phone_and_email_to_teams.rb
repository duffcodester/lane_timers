class AddPhoneAndEmailToTeams < ActiveRecord::Migration[8.1]
  def change
    add_column :teams, :phone, :string
    add_column :teams, :email, :string
  end
end
