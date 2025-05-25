require "csv"

class Booking < ApplicationRecord
  belongs_to :bookings_import, optional: true

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

  def self.import(file, bookings_import:, csv_mapping: {})
    successes = 0
    errors = []

    # Read file first lines to detect column separator
    first_lines = file.read(1024)
    file.rewind

    semicolon_count = first_lines.count(";")
    comma_count = first_lines.count(",")

    # The one with the highest count is the separator
    col_sep = semicolon_count > comma_count ? ";" : ","

    CSV.foreach(file.path, col_sep:, encoding: "bom|utf-8", headers: true) do |row|
      begin
        # Dynamically map CSV columns to model attributes
        attributes = {}

        csv_mapping.each do |model_attr, csv_column_name|
          attributes[model_attr] = row[csv_column_name]
        end

        # Store mapping used for the import in the jsonb column
        attributes[:csv_mapping] = csv_mapping
        # Associate booking to the import event
        attributes[:bookings_import_id] = bookings_import.id

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
