module Api
  module V1
    class BookingsController < ApplicationController
      def import
         file = params[:file]
        return render json: { error: "No file sent" }, status: :bad_request unless file

        begin
          Booking.import(file)
          render json: { message: "Successfully imported" }, status: :ok
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
    end
  end
end
