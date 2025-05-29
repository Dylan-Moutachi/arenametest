describe Api::V1::BookingsController, type: :controller do
  describe 'GET #index' do
    let!(:booking1) { create(:booking, event: 'Event A', age: 20, price: 10.5, email: 'a@example.com') }
    let!(:booking2) { create(:booking, event: 'Event B', age: 30, price: 20.5, email: 'b@example.com') }
    let!(:booking3) { create(:booking, event: 'Event A', age: nil, price: 15.0, email: 'a@example.com') }

    context 'without filter params' do
      it 'returns all bookings with correct stats and pagination' do
        get :index, params: {}

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json['bookings'].length).to eq(3)

        expect(json['pagination']['current_page']).to eq(1)
        expect(json['pagination']['per_page']).to eq(20)
        expect(json['pagination']['total_count']).to eq(3)
      end
    end

    context 'with show filter' do
      it 'returns only bookings matching the event filter (case insensitive)' do
        get :index, params: { event: 'event a' }

        json = JSON.parse(response.body)
        expect(json['bookings'].length).to eq(2)
        json['bookings'].each do |booking|
          expect(booking['event'].downcase).to include('event a')
        end
      end
    end

    context 'with pagination params' do
      before do
        create_list(:booking, 30, event: 'Event C', age: 25, price: 12.0, email: 'c@example.com')
      end

      it 'paginates results' do
        get :index, params: { page: 2, per_page: 20 }

        json = JSON.parse(response.body)
        expect(json['bookings'].length).to eq(13)
        expect(json['pagination']['current_page']).to eq(2)
        expect(json['pagination']['per_page']).to eq(20)
        expect(json['pagination']['total_pages']).to eq(2)
      end
    end
  end

  describe 'POST #import' do
    let(:file) { fixture_file_upload('sample.csv', 'text/csv') }

    context 'when no file is sent' do
      it 'returns bad_request and error message' do
        post :import, params: {}

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('No file sent')
      end
    end

    context 'when file is too large' do
      let(:large_file) do
        file = Tempfile.new('large.csv')
        file.write('a' * (Api::V1::BookingsController::MAX_FILE_SIZE_MB.megabytes + 1))
        file.rewind
        fixture_file_upload(file.path, 'text/csv')
      end

      after { large_file.tempfile.close! }

      it 'returns bad_request with file size error' do
        post :import, params: { file: large_file }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['error']).to include('File is too large')
      end
    end

    context 'when valid file is sent' do
      it 'enqueues ImportBookingsJob and returns accepted' do
        ImportBookingsJob.expects(:perform_async).once

        post :import, params: { file: file }

        expect(response).to have_http_status(:accepted)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('File upload received. Import is being processed in background.')
      end
    end
  end
end
