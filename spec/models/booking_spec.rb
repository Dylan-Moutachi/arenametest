require "tempfile"

RSpec.describe Booking, type: :model do
  describe "import" do
    let(:bookings_import) { create(:bookings_import) }

    let(:valid_csv_content) do
      <<~CSV
        Numero billet;Reservation;Date reservation;Heure reservation;Cle spectacle;Spectacle;Cle representation;Representation;Date representation;Heure representation;Date fin representation;Heure fin representation;Prix;Type de produit;Filiere de vente;Prenom;Nom;Email;Adresse;Code postal;Pays;Age;Sexe
        1234567;1001;2023-01-01;10:00;EVT001;Concert;SHW001;Soirée;2023-01-10;20:00;2023-01-10;22:00;30.0;Billet standard;Online;Alice;Durand;alice@example.com;1 rue Test;75000;France;30;F
        2345678;1002;2023-01-02;11:00;EVT002;Spectacle;SHW002;Matinée;2023-01-11;15:00;2023-01-11;17:00;25.0;Billet standard;Online;Bob;Martin;bob@example.com;2 avenue Exemple;69000;France;40;M
      CSV
    end

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

    def create_temp_csv(content)
      file = Tempfile.new([ "bookings", ".csv" ])
      file.write(content)
      file.rewind
      file
    end

    it "imports valid rows and returns successes and errors" do
      file = create_temp_csv(valid_csv_content)

      result = described_class.import(file, bookings_import:, csv_mapping:)

      expect(result[:successes]).to eq(2)
      expect(result[:errors]).to be_empty
      expect(Booking.count).to eq(2)

      file.close
      file.unlink
    end

    context "with duplicate ticket_number" do
      let(:duplicate_csv_content) do
        <<~CSV
          Numero billet;Reservation;Date reservation;Heure reservation;Cle spectacle;Spectacle;Cle representation;Representation;Date representation;Heure representation;Date fin representation;Heure fin representation;Prix;Type de produit;Filiere de vente;Prenom;Nom;Email;Adresse;Code postal;Pays;Age;Sexe
          1111111;1003;2023-02-01;12:00;EVT003;Pièce;SHW003;Soirée;2023-02-10;19:00;2023-02-10;21:00;20.0;Billet standard;Online;Claire;Noel;claire@example.com;3 rue Dupont;31000;France;28;F
          1111111;1004;2023-02-02;13:00;EVT004;Ballet;SHW004;Matinée;2023-02-11;14:00;2023-02-11;16:00;22.0;Billet standard;Online;David;Moreau;david@example.com;4 rue Martin;13000;France;35;M
        CSV
      end

      it "imports the first and skips the duplicate" do
        file = create_temp_csv(duplicate_csv_content)
        result = described_class.import(file, bookings_import: bookings_import, csv_mapping: csv_mapping)

        expect(result[:successes]).to eq(1)
        expect(result[:errors].length).to eq(1)
        expect(result[:errors].first[:messages]).to include("Ticket number has already been taken")
        expect(Booking.count).to eq(1)

        file.close
        file.unlink
      end
    end

    context "with optional fields missing" do
      let(:partial_csv_content) do
        <<~CSV
          Numero billet;Reservation;Date reservation;Heure reservation;Cle spectacle;Spectacle;Cle representation;Representation;Date representation;Heure representation;Date fin representation;Heure fin representation;Prix;Type de produit;Filiere de vente;Prenom;Nom;Email;Adresse;Code postal;Pays
          3456789;1005;2023-03-01;14:00;EVT005;Opéra;SHW005;Soirée;2023-03-15;20:00;2023-03-15;22:00;40.0;Billet premium;Online;Emma;Bernard;emma@example.com;5 rue Silence;67000;France
        CSV
      end

      let(:partial_mapping) do
        csv_mapping.except("age", "gender")
      end

      it "imports successfully even without optional fields" do
        file = create_temp_csv(partial_csv_content)
        result = described_class.import(file, bookings_import: bookings_import, csv_mapping: partial_mapping)

        expect(result[:successes]).to eq(1)
        expect(result[:errors]).to be_empty
        expect(Booking.count).to eq(1)

        booking = Booking.last
        expect(booking.age).to be_nil
        expect(booking.gender).to be_nil

        file.close
        file.unlink
      end
    end
  end
end
