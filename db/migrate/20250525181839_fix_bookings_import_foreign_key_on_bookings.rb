class FixBookingsImportForeignKeyOnBookings < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :bookings, column: :bookings_import_id

    change_column_null :bookings, :bookings_import_id, true

    add_foreign_key :bookings, :bookings_imports, column: :bookings_import_id, on_delete: :nullify
  end
end
