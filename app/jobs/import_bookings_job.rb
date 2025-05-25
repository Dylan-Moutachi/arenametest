class ImportBookingsJob < ApplicationSidekiqJob
  def perform(file_path, csv_mapping = {}, bookings_import_id)
    bookings_import = BookingsImport.find(bookings_import_id)

    begin
      File.open(file_path, "r") do |file|
        result = Booking.import(file, bookings_import:, csv_mapping:)

        status =
          if result[:successes] == 0 && result[:errors].any?
            "failed"
          elsif result[:errors].any?
            "partial_success"
          else
            "success"
          end

        bookings_import.update!(
          status: status,
          successes: result[:successes],
          error_list: result[:errors]
        )
      end
    rescue => e
      Rails.logger.error "ImportBookingsJob failed: #{e.message}"
      bookings_import.update!(
        status: "failed",
        successes: 0,
        error_list: [ e.message ]
      )
    ensure
      File.delete(file_path) if File.exist?(file_path)
    end
  end
end
