class AddImportToBookings < ActiveRecord::Migration[8.0]
  def change
    add_reference :bookings, :import, null: false, foreign_key: true
  end
end
