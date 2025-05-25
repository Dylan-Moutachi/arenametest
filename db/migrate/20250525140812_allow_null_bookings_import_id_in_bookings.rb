class AllowNullBookingsImportIdInBookings < ActiveRecord::Migration[8.0]
  def change
    change_column_null :bookings, :bookings_import_id, true
  end
end
