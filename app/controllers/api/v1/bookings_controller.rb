module Api
  module V1
    class BookingsController < ApplicationController
      # I set the constant MULTI_STATUS for the case when some lines
      # are successfully imported and other lines failed to be imported
      MULTI_STATUS = 207

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
