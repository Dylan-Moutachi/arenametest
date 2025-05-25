RSpec.describe BookingsImport, type: :model do
  describe "validations" do
    it "is valid with a valid status" do
      bookings_import = build(:bookings_import, status: "processing")
      expect(bookings_import).to be_valid
    end

    it "is invalid without a status" do
      bookings_import = build(:bookings_import, status: nil)
      expect(bookings_import).not_to be_valid
      expect(bookings_import.errors[:status]).to include("can't be blank")
    end

    it "is invalid with a status outside of the allowed list" do
      bookings_import = build(:bookings_import, status: "invalid_status")
      expect(bookings_import).not_to be_valid
      expect(bookings_import.errors[:status]).to include("is not included in the list")
    end
  end

  describe "associations" do
    it "has many bookings and nullifies bookings on destroy" do
      bookings_import = create(:bookings_import)
      booking = create(:booking, bookings_import:)

      expect(bookings_import.bookings).to include(booking)

      bookings_import.destroy

      expect(Booking.exists?(booking.id)).to be true
      expect(Booking.find(booking.id).bookings_import_id).to be_nil
    end
  end
end
