class ChangeAgeToIntegerInBookings < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      ALTER TABLE bookings
      ALTER COLUMN age TYPE integer USING age::integer;
    SQL
  end

  def down
    change_column :bookings, :age, :string
  end
end
