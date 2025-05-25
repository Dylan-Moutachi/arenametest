class ChangePriceToFloatInBookings < ActiveRecord::Migration[8.0]
  def up
    change_column :bookings, :price, :float
  end

  def down
    change_column :bookings, :price, :decimal, precision: 10, scale: 2
  end
end
