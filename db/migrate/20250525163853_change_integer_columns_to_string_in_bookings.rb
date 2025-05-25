class ChangeIntegerColumnsToStringInBookings < ActiveRecord::Migration[8.0]
  def up
    change_column :bookings, :booking_number, :string
    change_column :bookings, :age, :string
    change_column :bookings, :ticket_number, :string
  end

  def down
    change_column :bookings, :booking_number, :integer
    change_column :bookings, :age, :integer
    change_column :bookings, :ticket_number, :integer
  end
end
