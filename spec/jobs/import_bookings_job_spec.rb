RSpec.describe ImportBookingsJob, type: :job do
  let!(:bookings_import) { BookingsImport.create!(status: "processing") }

  let(:fixture_path) { Rails.root.join("spec", "fixtures", "files", "sample.csv") }

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

  it "imports bookings, updates BookingsImport and deletes the temporary file" do
    temp_file_path = "#{fixture_path}.tmp"
    FileUtils.cp(fixture_path, temp_file_path)

    expect {
      job.perform(temp_file_path, csv_mapping, bookings_import.id)
    }.to change(Booking, :count).by_at_least(1)

    bookings_import.reload

    expect(bookings_import.status).to be_in(%w[success partial_success])
    expect(bookings_import.successes).to be > 0
    expect(bookings_import.error_list).to be_an(Array)
    expect(File.exist?(temp_file_path)).to be_falsey
  end

  context "when the import file contains only duplicate rows" do
    it "marks the BookingsImport as failed" do
      temp_file_path = "#{fixture_path}.only_duplicates.csv"
      FileUtils.cp(fixture_path, temp_file_path)

      # First import to create bookings
      job.perform(temp_file_path, csv_mapping, bookings_import.id)
      expect(Booking.count).to be > 0

      # Create a new bookings_import for second import
      second_import = BookingsImport.create!(status: "processing")

      # Second import, expected to fail because of duplicates
      expect {
        job.perform(temp_file_path, csv_mapping, second_import.id)
      }.to change(BookingsImport, :count).by(0) # no new import created inside job

      second_import.reload

      expect(second_import.status).to eq("failed")
      expect(second_import.successes).to eq(0)
      expect(second_import.error_list).to all(be_a(String))
      expect(second_import.error_list.size).to be > 0

      File.delete(temp_file_path) if File.exist?(temp_file_path)
    end
  end

  context "when an error occurs during import" do
  it "logs the error" do
    # Pass a non-existent file path and expect a log error
    Rails.logger.expects(:error).with(regexp_matches(/ImportBookingsJob failed:/)).once

    job.perform("/tmp/non_existent_file.csv", csv_mapping, bookings_import.id)
  end
end
end
