class AddFieldsToBookings < ActiveRecord::Migration[6.1]
  def change
    change_table :bookings, bulk: true do |t|
      t.string :booking_date
      t.string :booking_hour
      t.string :event_key
      t.string :event
      t.string :show_key
      t.string :hour
      t.string :show_end_date
      t.string :show_end_hour
      t.string :product_type
      t.string :sales_channel
      t.string :email
      t.string :address
      t.string :postal_code
      t.string :country
    end
  end
end
