class ImportBookingsJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    # Open the file safely
    # If we want to automatically detect encoding, we can use charlock_holmes
    File.open(file_path, "r:bom|utf-8") do
      result = Booking.import(it)

      # Log import summary
      Rails.logger.info "ImportBookingsJob finished: #{result[:successes]} imported, #{result[:errors].count} errors"
    end
  rescue => e
    Rails.logger.error "ImportBookingsJob failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  ensure
    # Clean up temporary file
    File.delete(file_path) if File.exist?(file_path)
  end
end
