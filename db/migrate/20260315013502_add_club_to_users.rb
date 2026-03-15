class AddClubToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :club, null: true, foreign_key: true
  end
end
