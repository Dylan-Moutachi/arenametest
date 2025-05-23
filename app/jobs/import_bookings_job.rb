class ImportBookingsJob < ApplicationSidekiqJob
  def perform(file_path)
    begin
      File.open(file_path, "r") do |file|
        result = Booking.import(file)
        Rails.logger.info "ImportBookingsJob finished: #{result[:successes]} bookings imported, #{result[:errors].count} errors"
      end
    rescue => e
      Rails.logger.error "ImportBookingsJob failed: #{e.message}"
    ensure
      File.delete(file_path) if File.exist?(file_path)
    end
  end
end
