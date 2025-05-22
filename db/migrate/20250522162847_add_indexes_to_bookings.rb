class AddIndexesToBookings < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :bookings, :ticket_number, unique: true, algorithm: :concurrently

    add_index :bookings, :show, algorithm: :concurrently

    add_index :bookings, :email, algorithm: :concurrently
  end
end
