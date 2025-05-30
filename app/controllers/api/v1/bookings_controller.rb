module Api
  module V1
    class BookingsController < ApplicationController
      # I set the constant MULTI_STATUS for the case when some lines
      # are successfully imported and other lines failed to be imported
      MULTI_STATUS = 207

      # In order to prevent swapping on sidekiq, I set a maximum file size
      # With 100MB as max file size and 2 sidekiq threads, the server will take at most 200MB RAM
      # If I deploy with my Heroku account with 512MB max memory, I leave 300MB for the system
      MAX_FILE_SIZE_MB = 100 # Allows about 100,000 lines. Around the Stade de France stadium capacity

      def index
        bookings = Booking.all

        # event search function
        if params[:event].present?
          bookings = bookings.where("LOWER(event) LIKE ?", "%#{params[:event].downcase}%")
        end

        # Kaminari pagination
        page_number = params[:page] || 1
        per_page = params[:per_page] || 20

        paginated_bookings = bookings.page(page_number).per(per_page)

        render json: {
          bookings: ActiveModelSerializers::SerializableResource.new(paginated_bookings, each_serializer: BookingSerializer),
          stats: Booking.global_stats(bookings),
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

        # Ensure file sent is a CSV MIME type (avoid potential code injections)
        allowed_mime_types = [ "text/csv", "application/csv", "text/plain" ]
        real_mime_type = Marcel::MimeType.for(file.path, name: file.original_filename)
        unless allowed_mime_types.include?(real_mime_type)
          return render json: { error: "File content type unauthorized (detected: #{real_mime_type})." }, status: :bad_request
        end

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

          # Create the BookingsImport here with status processing
          bookings_import = BookingsImport.create!(status: "processing")

          # Enqueue job with file path, mapping, and bookings_import id
          ImportBookingsJob.perform_async(tmp_file_path.to_s, csv_mapping, bookings_import.id)

          # Return the id so front can poll status later
          render json: { message: "File upload received. Import is being processed in background.", bookings_import_id: bookings_import.id }, status: :accepted
        rescue StandardError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
    end
  end
end
