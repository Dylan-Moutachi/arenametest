RSpec.describe CsvReaderService do
  describe ".convert_to_utf8" do
    let(:original_content) { "raw data".force_encoding("ISO-8859-1") }
    let(:detected_encoding) { "ISO-8859-1" }
    let(:converted_content) { "raw data".encode("UTF-8") }

    it "detects encoding and converts to UTF-8" do
      CharlockHolmes::EncodingDetector.expects(:detect)
        .with(original_content)
        .returns({ encoding: detected_encoding })

      CharlockHolmes::Converter.expects(:convert)
        .with(original_content, detected_encoding, "UTF-8")
        .returns(converted_content)

      result = CsvReaderService.convert_to_utf8(original_content)
      expect(result).to eq(converted_content)
    end

    it "raises an error if encoding cannot be detected" do
      CharlockHolmes::EncodingDetector.expects(:detect)
        .with(original_content)
        .returns(nil)

      expect {
        CsvReaderService.convert_to_utf8(original_content)
      }.to raise_error(StandardError, /Encoding could not be detected/)
    end

    it "raises an error if conversion fails" do
      CharlockHolmes::EncodingDetector.expects(:detect)
        .with(original_content)
        .returns({ encoding: detected_encoding })

      CharlockHolmes::Converter.expects(:convert)
        .with(original_content, detected_encoding, "UTF-8")
        .raises(StandardError.new("boom"))

      expect {
        CsvReaderService.convert_to_utf8(original_content)
      }.to raise_error(StandardError, /Failed to convert to UTF-8: boom/)
    end
  end
end
