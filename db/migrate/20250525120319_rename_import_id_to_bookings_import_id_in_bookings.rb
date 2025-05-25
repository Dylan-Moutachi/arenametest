class RenameImportIdToBookingsImportIdInBookings < ActiveRecord::Migration[8.0]
  def change
    rename_column :bookings, :import_id, :bookings_import_id
  end
end
