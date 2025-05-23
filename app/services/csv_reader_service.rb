require "charlock_holmes"

class CsvReaderService
  def self.convert_to_utf8(content)
    detection = CharlockHolmes::EncodingDetector.detect(content)
    raise StandardError, "Encoding could not be detected" unless detection&.dig(:encoding)

    CharlockHolmes::Converter.convert(content, detection[:encoding], "UTF-8")
  rescue StandardError => e
    raise StandardError, "Failed to convert to UTF-8: #{e.message}"
  end
end
