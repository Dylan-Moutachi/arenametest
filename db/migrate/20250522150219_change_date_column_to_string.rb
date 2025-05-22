class ChangeDateColumnToString < ActiveRecord::Migration[8.0]
   def change
    remove_column :bookings, :date, :date

    add_column :bookings, :show_date, :string
  end
end
