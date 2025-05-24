require "csv"

class Booking < ApplicationRecord
  # Some fields like age and gender are not always provided
  validates :ticket_number, :booking_number, :booking_date, :booking_hour,
            :event_key, :event, :show_key, :show, :show_date, :show_hour,
            :show_end_date, :show_end_hour, :price,
            :product_type, :sales_channel,
            :first_name, :last_name, :email,
            :address, :postal_code, :country,
            presence: true

  # Ticket logically seems unique
  validates :ticket_number, uniqueness: true

  def self.import(file, csv_mapping: {})
    successes = 0
    errors = []

    CSV.foreach(file.path, headers: true, col_sep: ";", encoding: "utf-8") do |row|
      begin
        # Dynamically map CSV columns to model attributes
        attributes = {}

        csv_mapping.each do |model_attr, csv_column_name|
          attributes[model_attr] = row[csv_column_name]
        end

        # Store mapping used for this import in the jsonb column
        attributes[:csv_mapping] = csv_mapping

        Booking.create!(attributes)
        successes += 1
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Ignored line: #{row.to_h} – error: #{e.message}"
        errors << { row: row.to_h, messages: e.record.errors.full_messages }
      end
    end

    { successes:, errors: }
  end
end
