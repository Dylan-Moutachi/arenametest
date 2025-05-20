class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.integer :booking_number
      t.string :show
      t.date :date
      t.float :price
      t.string :last_name
      t.string :first_name
      t.integer :age
      t.string :gender

      t.timestamps
    end
  end
end
