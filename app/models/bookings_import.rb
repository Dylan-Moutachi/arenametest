class BookingsImport < ApplicationRecord
  has_many :bookings, dependent: :nullify

  STATUSES = %w[processing success partial_success failed].freeze

  validates :status, inclusion: { in: STATUSES }, presence: true
end
