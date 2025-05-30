describe Api::V1::BookingsController, type: :controller do
  describe "GET #index" do
    let!(:booking1) { create(:booking, event: "Event A", age: 20, price: 10.5, email: "a@example.com") }
    let!(:booking2) { create(:booking, event: "Event B", age: 30, price: 20.5, email: "b@example.com") }
    let!(:booking3) { create(:booking, event: "Event A", age: nil, price: 15.0, email: "a@example.com") }

    context "without filter params" do
      it "returns all bookings with correct stats and pagination" do
        get :index, params: {}

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["bookings"].length).to eq(3)

        expect(json["pagination"]["current_page"]).to eq(1)
        expect(json["pagination"]["per_page"]).to eq(20)
        expect(json["pagination"]["total_count"]).to eq(3)
      end
    end

    context "with show filter" do
      it "returns only bookings matching the event filter (case insensitive)" do
        get :index, params: { event: "event a" }

        json = JSON.parse(response.body)
        expect(json["bookings"].length).to eq(2)
        json["bookings"].each do |booking|
          expect(booking["event"].downcase).to include("event a")
        end
      end
    end

    context "with pagination params" do
      before do
        create_list(:booking, 30, event: "Event C", age: 25, price: 12.0, email: "c@example.com")
      end

      it "paginates results" do
        get :index, params: { page: 2, per_page: 20 }

        json = JSON.parse(response.body)
        expect(json["bookings"].length).to eq(13)
        expect(json["pagination"]["current_page"]).to eq(2)
        expect(json["pagination"]["per_page"]).to eq(20)
        expect(json["pagination"]["total_pages"]).to eq(2)
      end
    end
  end

  describe "POST #import" do
    let(:file) { fixture_file_upload("sample.csv", "text/csv") }

    context "when no file is sent" do
      it "returns bad_request and error message" do
        post :import, params: {}

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("No file sent")
      end
    end

    context "when file has invalid MIME type detected by Marcel gem" do
      let(:original_fake_path) { Rails.root.join("spec", "fixtures", "files", "fake_script.rb") }
      let(:temp_fake_path) { Rails.root.join("tmp", "fake_script_copy.rb") }

      before do
        FileUtils.cp(original_fake_path, temp_fake_path)
      end

      let(:fake_csv_file) do
        fixture_file_upload(temp_fake_path, "text/csv", original_filename: "fake.csv")
      end

      after do
        File.delete(temp_fake_path) if File.exist?(temp_fake_path)
      end

      it "rejects the file and returns bad_request" do
        post :import, params: { file: fake_csv_file }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to match(/File content type unauthorized/)
      end
    end

    context "when file is too large" do
      let(:large_file_path) { Rails.root.join("tmp", "large_test_file.csv") }
      let(:large_file) { fixture_file_upload(large_file_path, "text/csv") }

      # I create the large file only during the test to avoid committing large files
      before do
        CSV.open(large_file_path, "wb") do |csv|
          csv << [
            "ticket_number",
            "booking_number",
            "booking_date",
            "booking_hour",
            "event_key",
            "event",
            "show_key",
            "show",
            "show_date",
            "show_hour",
            "show_end_date",
            "show_end_hour",
            "price",
            "product_type",
            "sales_channel",
            "last_name",
            "first_name",
            "email",
            "address",
            "postal_code",
            "country",
            "age",
            "gender"
          ]
          600_000.times do |i|
            csv << [
              "T#{i}",
              "B#{i}",
              "2025-01-01",
              "19:00",
              "EK#{i % 100}",
              "Event C",
              "SK#{i % 50}",
              "Show Name",
              "2025-01-15",
              "20:00",
              "2025-01-15",
              "22:00",
              "12.00",
              "Standard",
              "Online",
              "Doe",
              "John",
              "john.doe@example.com",
              "123 Street",
              "12345",
              "Country",
              "30",
              "M"
            ]
          end
        end
      end

      after do
        File.delete(large_file_path) if File.exist?(large_file_path)
      end

      it "returns bad_request with file size error" do
        post :import, params: { file: large_file }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to include("File is too large")
      end
    end

    context "when valid file is sent" do
      it "enqueues ImportBookingsJob and returns accepted" do
        ImportBookingsJob.expects(:perform_async).once

        post :import, params: { file: file }

        expect(response).to have_http_status(:accepted)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("File upload received. Import is being processed in background.")
      end
    end
  end
end
