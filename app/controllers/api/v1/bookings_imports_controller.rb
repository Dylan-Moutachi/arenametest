class Api::V1::BookingsImportsController < ApplicationController
  def show
    render json: BookingsImport.find(params[:id])
  end
end
