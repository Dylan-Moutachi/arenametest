class ChangePriceToDecimalInBookings < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      ALTER TABLE bookings
      ALTER COLUMN price TYPE decimal(10, 2) USING price::decimal;
    SQL
  end

  def down
    change_column :bookings, :price, :float
  end
end
