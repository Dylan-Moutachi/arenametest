class ChangeHourColumnToString < ActiveRecord::Migration[8.0]
  def change
    remove_column :bookings, :hour, :string

    add_column :bookings, :show_hour, :string
  end
end
