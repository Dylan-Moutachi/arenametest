class Api::V1::BookingsImportsController < ApplicationController
  def status
    import = BookingsImport.find(params[:id])

    render json: {
      status: import.status,
      successes: import.successes || 0,
      errors: import.error_list || [],
      started_at: import.created_at,
      finished_at: import.updated_at
    }
  end
end
