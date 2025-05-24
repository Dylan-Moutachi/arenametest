require "csv"

class Booking < ApplicationRecord
  # regarding sample csv, age and gender are not always provided
  # so I suppose these are not mandatory informations.
  validates :ticket_number, :booking_number, :booking_date, :booking_hour,
          :event_key, :event, :show_key, :show, :show_date, :show_hour,
          :show_end_date, :show_end_hour, :price,
          :product_type, :sales_channel,
          :first_name, :last_name, :email,
          :address, :postal_code, :country,
          presence: true
  validates :ticket_number, uniqueness: true

  def self.import(file)
    successes = 0
    errors = []
    # Ideally, we can variabilize CSV parsing arguments
    # CSV.foreach(file.path, **options) ...
    CSV.foreach(file.path, headers: true, col_sep: ";", encoding: "utf-8") do |row|
      begin
        Booking.create!(
          ticket_number: row["Numero billet"],
          booking_number: row["Reservation"],
          booking_date: row["Date reservation"],
          booking_hour: row["Heure reservation"],
          event_key: row["Cle spectacle"],
          event: row["Spectacle"],
          show_key: row["Cle representation"],
          show: row["Representation"],
          show_date: row["Date representation"],
          show_hour: row["Heure representation"],
          show_end_date: row["Date fin representation"],
          show_end_hour: row["Heure fin representation"],
          price: row["Prix"],
          product_type: row["Type de produit"],
          sales_channel: row["Filiere de vente"],
          first_name: row["Prenom"],
          last_name: row["Nom"],
          email: row["Email"],
          address: row["Adresse"],
          postal_code: row["Code postal"],
          country: row["Pays"],
          age: row["Age"],
          gender: row["Sexe"]
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
