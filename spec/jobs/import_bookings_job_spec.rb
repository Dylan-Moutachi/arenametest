RSpec.describe ImportBookingsJob, type: :job do
  let(:fixture_path) { Rails.root.join("spec", "fixtures", "files", "sample.csv") }
  let(:temp_file_path) { "#{fixture_path}.tmp" }

  subject(:job) { described_class.new }

  before do
    FileUtils.cp(fixture_path, temp_file_path)
  end

  after do
    File.delete(temp_file_path) if File.exist?(temp_file_path)
  end

  it "imports bookings and deletes the temporary file" do
    initial_count = Booking.count

    job.perform(temp_file_path)

    expect(Booking.count).to be > initial_count
    expect(File.exist?(temp_file_path)).to be_falsey
  end

  it "logs success message" do
    Rails.logger.expects(:info).with(regexp_matches(/ImportBookingsJob finished: \d+ bookings imported, \d+ errors/)).once

    job.perform(temp_file_path)
  end

  context "when an error occurs during import" do
    it "logs the error message" do
      Rails.logger.expects(:error).with(regexp_matches(/ImportBookingsJob failed:/)).once

      job.perform("/tmp/non_existent_file.csv")
    end
  end
end
