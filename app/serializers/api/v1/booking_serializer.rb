class Api::V1::BookingSerializer < ActiveModel::Serializer
  attributes :id, :last_name, :first_name, :age, :price, :booking_number, :show
end
