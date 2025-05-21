class AddTicketNumberToBooking < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :ticket_number, :integer
  end
end
