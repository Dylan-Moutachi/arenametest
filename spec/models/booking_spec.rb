require "tempfile"

RSpec.describe Booking, type: :model do
  describe "import" do
    let(:valid_csv_content) do
      <<~CSV
        Numero billet;Reservation;Date reservation;Heure reservation;Cle spectacle;Spectacle;Cle representation;Representation;Date representation;Heure representation;Date fin representation;Heure fin representation;Prix;Type de produit;Filiere de vente;Prenom;Nom;Email;Adresse;Code postal;Pays;Age;Sexe
        1234567;1001;2023-01-01;10:00;EVT001;Concert;SHW001;Soirée;2023-01-10;20:00;2023-01-10;22:00;30.0;Billet standard;Online;Alice;Durand;alice@example.com;1 rue Test;75000;France;30;F
        2345678;1002;2023-01-02;11:00;EVT002;Spectacle;SHW002;Matinée;2023-01-11;15:00;2023-01-11;17:00;25.0;Billet standard;Online;Bob;Martin;bob@example.com;2 avenue Exemple;69000;France;40;M
      CSV
    end

    let(:invalid_csv_content) do
      <<~CSV
        Numero billet;Reservation;Date reservation;Heure reservation;Cle spectacle;Spectacle;Cle representation;Representation;Date representation;Heure representation;Date fin representation;Heure fin representation;Prix;Type de produit;Filiere de vente;Prenom;Nom;Email;Adresse;Code postal;Pays;Age;Sexe
        ;;;;;;;Invalid;;;;;;Missing;;;;;;
      CSV
    end

    def create_temp_csv(content)
      file = Tempfile.new(["bookings", ".csv"])
      file.write(content)
      file.rewind
      file
    end

    it "imports valid rows and returns successes and errors" do
      file = create_temp_csv(valid_csv_content)

      result = described_class.import(file)

      expect(result[:successes]).to eq(2)
      expect(result[:errors]).to be_empty
      expect(Booking.count).to eq(2)

      file.close
      file.unlink
    end

    it "skips invalid rows and returns errors" do
      file = create_temp_csv(invalid_csv_content)

      result = described_class.import(file)

      expect(result[:successes]).to eq(0)
      expect(result[:errors].length).to eq(1)
      expect(Booking.count).to eq(0)

      file.close
      file.unlink
    end
  end
end
