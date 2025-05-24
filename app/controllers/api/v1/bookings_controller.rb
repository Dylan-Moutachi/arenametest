module Api
  module V1
    class BookingsController < ApplicationController
      # I set the constant MULTI_STATUS for the case when some lines
      # are successfully imported and other lines failed to be imported
      MULTI_STATUS = 207

      # In order to prevent swapping on sidekiq, I set a maximum file size
      # With 100MB as max file size and 2 sidekiq threads, the server will take at most 200MB RAM
      # If I deploy with my Heroku account with 512GB max memory, I leave 300MB for the system
      MAX_FILE_SIZE_MB = 100 # Allows about 100,000 lines. Around the Stade de France stadium capacity

      def index
        bookings = Booking.all

        if params[:show].present?
          bookings = bookings.where("LOWER(show) LIKE ?", "%#{params[:show].downcase}%")
        end

        # Kaminari pagination
        page_number = params[:page] || 1
        per_page = params[:per_page] || 20

        paginated_bookings = bookings.page(page_number).per(per_page)

        # stats not depending on pagination
        average_age = bookings.where.not(age: nil).average(:age)&.round || nil
        average_price = bookings.average(:price)&.round(2)
        total_revenue = bookings.sum(:price).round(2)
        booking_count = bookings.count
        unique_buyers_count = bookings.select(:email).distinct.count

        render json: {
          bookings: ActiveModelSerializers::SerializableResource.new(paginated_bookings, each_serializer: BookingSerializer),
          stats: {
            average_age: average_age,
            average_price: average_price,
            total_revenue: total_revenue,
            booking_count: booking_count,
            unique_buyers_count: unique_buyers_count
          },
          pagination: {
            current_page: paginated_bookings.current_page,
            total_pages: paginated_bookings.total_pages,
            per_page: paginated_bookings.limit_value,
            total_count: paginated_bookings.total_count
          }
        }
      end

      def import
        file = params[:file]
        return render json: { error: "No file sent" }, status: :bad_request unless file

        # Size limit
        if file.size > MAX_FILE_SIZE_MB.megabytes
          return render json: { error: "File is too large. Maximum allowed size is #{MAX_FILE_SIZE_MB} MB." }, status: :bad_request
        end

        begin
          # raw content read
          raw_content = file.read

          # utf8 converted content
          utf8_content = CsvReaderService.convert_to_utf8(raw_content)
          # write utf8 content in a temporary file
          tmp_file_path = Rails.root.join("tmp", "upload_#{SecureRandom.uuid}.csv")
          File.open(tmp_file_path, "wb") { |f| f.write(utf8_content) }

          # parse CSV mapping from frontend
          csv_mapping = params[:csv_mapping].present? ? JSON.parse(params[:csv_mapping]) : {}

          # Enqueue job with file path and mapping
          ImportBookingsJob.perform_async(tmp_file_path.to_s, csv_mapping)

          render json: { message: "File upload received. Import is being processed in background." }, status: :accepted
        rescue StandardError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
    end
  end
end
