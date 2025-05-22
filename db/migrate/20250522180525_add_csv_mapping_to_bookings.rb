class AddCsvMappingToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :csv_mapping, :jsonb, default: {}
  end
end
