class RenameImportsToBookingsImports < ActiveRecord::Migration[8.0]
  def change
    rename_table :imports, :bookings_imports
  end
end
