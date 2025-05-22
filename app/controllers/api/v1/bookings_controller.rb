module Api
  module V1
    class BookingsController < ApplicationController
      # I set the constant MULTI_STATUS for the case when some lines
      # are successfully imported and other lines failed to be imported
      MULTI_STATUS = 207

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
        unique_buyers_count = bookings.select(:first_name, :last_name).distinct.count

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

        begin
          result = Booking.import(file)

          if result[:successes] == 0
            render json: {
              error: "No lines were imported.",
              details: result[:errors]
            }, status: :unprocessable_entity
          elsif result[:errors].any?
            render json: {
              message: "Import completed with some errors.",
              imported: result[:successes],
              errors: result[:errors]
            }, status: MULTI_STATUS
          else
            render json: { message: "Successfully imported #{result[:successes]} bookings." }, status: :ok
          end
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
    end
  end
end
