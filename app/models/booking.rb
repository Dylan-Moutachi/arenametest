require "csv"

class Booking < ApplicationRecord
  # regarding sample csv, age and gender are not always provided
  # so I suppose these are not mandatory informations.
  validates :first_name, :last_name, :booking_number, :show, :date, :price, :ticket_number, presence: true
  validates :ticket_number, uniqueness: true

  def self.import(file)
    successes = 0
    errors = []

    CSV.foreach(file.path, headers: true, col_sep: ";", encoding: "bom|utf-8") do |row|
      begin
        Booking.create!(
          ticket_number: row["ticket_number"],
          booking_number: row["booking_number"],
          show: row["show"],
          date: row["date"],
          price: row["price"],
          last_name: row["last_name"],
          first_name: row["first_name"],
          age: row["age"],
          gender: row["gender"]
        )
        successes += 1
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Ignored line: #{row.to_h} – error: #{e.message}"
        errors << { row: row.to_h, messages: e.record.errors.full_messages }
      end
    end

    { successes:, errors: }
  end
end
