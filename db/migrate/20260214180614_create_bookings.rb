class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :team, null: false, foreign_key: true
      t.integer :lane, null: false
      t.date :date, null: false
      t.time :start_time, null: false

      t.timestamps
    end

    add_index :bookings, [:lane, :date, :start_time], unique: true
  end
end
