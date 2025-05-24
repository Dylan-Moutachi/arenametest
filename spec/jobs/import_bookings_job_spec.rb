RSpec.describe ImportBookingsJob, type: :job do
  let(:fixture_path) { Rails.root.join("spec", "fixtures", "files", "sample.csv") }
  let(:temp_file_path) { "#{fixture_path}.tmp" }
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
      "first_name" => "Prenom",
      "last_name" => "Nom",
      "email" => "Email",
      "address" => "Adresse",
      "postal_code" => "Code postal",
      "country" => "Pays",
      "age" => "Age",
      "gender" => "Sexe"
    }
  end

  subject(:job) { described_class.new }

  before do
    FileUtils.cp(fixture_path, temp_file_path)
  end

  after do
    File.delete(temp_file_path) if File.exist?(temp_file_path)
  end

  it "imports bookings and deletes the temporary file" do
    initial_count = Booking.count

    job.perform(temp_file_path, csv_mapping)

    expect(Booking.count).to be > initial_count
    expect(File.exist?(temp_file_path)).to be_falsey
  end

  it "logs success message" do
    Rails.logger.expects(:info).with(regexp_matches(/ImportBookingsJob finished: \d+ bookings imported, \d+ errors/)).once

    job.perform(temp_file_path, csv_mapping)
  end

  context "when an error occurs during import" do
    it "logs the error message" do
      Rails.logger.expects(:error).with(regexp_matches(/ImportBookingsJob failed:/)).once

      job.perform("/tmp/non_existent_file.csv", csv_mapping)
    end
  end
end
