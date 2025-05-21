require "csv"

class Booking < ApplicationRecord
  # regarding sample csv, age and gender are not always provided
  # so I suppose these are not mandatory informations.
  validates :first_name, :last_name, :booking_number, :show, :date, :price, presence: true

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      # I would like to see if some lines are not imported
      # so I use begin and rescue to scan each one of them
      begin
        Booking.create!(
          booking_number: row["booking_number"],
          show: row["show"],
          date: row["date"],
          price: row["price"],
          last_name: row["last_name"],
          first_name: row["first_name"],
          age: row["age"],
          gender: row["gender"]
        )
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Ignored line: #{row.to_h} – error : #{e.message}"
      end
    end
  end
end
