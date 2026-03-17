class AddPriorityToClubs < ActiveRecord::Migration[8.1]
  def change
    add_column :clubs, :priority, :integer, default: 0
  end
end
