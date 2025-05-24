require 'sidekiq/testing'
require 'tempfile'
require 'fileutils'

RSpec.describe "Bookings Import", type: :request do
  let(:csv_file_path) { Rails.root.join("spec/fixtures/files/sample.csv") }
  let(:csv_mapping) do
    {
      "ticket_number" => "Numero billet",
      "booking_number" => "Reservation",
      "booking_date" => "Date reservation",
      "booking_hour" => "Heure reservation",
      "event_key" => "Cle spectacle",
      "event" => "Spectacle",
      "show_key" => "Cle representation",
      "show" => "Representation",
      "show_date" => "Date representation",
      "show_hour" => "Heure representation",
      "show_end_date" => "Date fin representation",
      "show_end_hour" => "Heure fin representation",
      "price" => "Prix",
      "product_type" => "Type de produit",
      "sales_channel" => "Filiere de vente",
      "last_name" => "Nom",
      "first_name" => "Prenom",
      "email" => "Email",
      "address" => "Adresse",
      "postal_code" => "Code postal",
      "country" => "Pays"
    }
  end

  before do
    Booking.delete_all
    Sidekiq::Testing.inline!
  end

  after do
    Sidekiq::Queues.clear_all
  end

  it "imports bookings from real CSV file" do
    # I use a temporary file to copy sample.csv in order to prevent it to be deleted at the end of the process
    Tempfile.open([ "sample", ".csv" ]) do |tempfile|
      FileUtils.cp(csv_file_path, tempfile.path)
      uploaded_file = Rack::Test::UploadedFile.new(tempfile.path, "text/csv")

      expect {
        post "/api/v1/bookings/import", params: {
          file: uploaded_file,
          csv_mapping: csv_mapping.to_json
        }
      }.to change(Booking, :count).by(99) # 99 lines in file

      expect(response).to have_http_status(:accepted)

      booking = Booking.last
      expect(booking).not_to be_nil

      # Verify presence of required fields
      required_fields = %i[
        ticket_number booking_number booking_date booking_hour
        event_key event show_key show show_date show_hour
        show_end_date show_end_hour price product_type sales_channel
        last_name first_name email address postal_code country
      ]

      required_fields.each do |field|
        expect(booking.send(field)).to be_present, "#{field} should be present" # string message if error
      end
    end
  end
end
