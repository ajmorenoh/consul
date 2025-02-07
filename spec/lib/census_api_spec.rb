require "rails_helper"

describe CensusApi do
  let(:api) { described_class.new }

  describe "#get_document_number_variants" do
    it "trims and cleans up entry" do
      expect(api.get_document_number_variants(2, "  1 2@ 34")).to eq(["1234"])
    end

    it "returns only one try for passports & residence cards" do
      expect(api.get_document_number_variants(2, "1234")).to eq(["1234"])
      expect(api.get_document_number_variants(3, "1234")).to eq(["1234"])
    end

    it "takes only the last 8 digits for dnis and resicence cards" do
      expect(api.get_document_number_variants(1, "543212345678")).to eq(%w(12345678 12345678z 12345678Z))
    end

    it "tries all the dni variants padding with zeroes" do
      expect(api.get_document_number_variants(1, "0123456")).to eq(%w(123456 0123456 00123456 123456s 123456S 0123456s 0123456S 00123456s 00123456S))
      expect(api.get_document_number_variants(1, "00123456")).to eq(%w(123456 0123456 00123456 123456s 123456S 0123456s 0123456S 00123456s 00123456S))
    end

    it "adds upper and lowercase letter when the letter is present" do
      expect(api.get_document_number_variants(1, "1234567L")).to eq(%w(1234567 01234567 1234567l 1234567L 01234567l 01234567L))
    end

    it "adds letter if not present" do
      expect(api.get_document_number_variants(1, "1234567")).to eq(%w(1234567 01234567 1234567l 1234567L 01234567l 01234567L))
    end

    it "uses the correct letter for a spanish document number" do
      expect(api.get_document_number_variants(1, "1234567B")).to eq(%w(1234567 01234567 1234567l 1234567L 01234567l 01234567L))
    end
  end

  describe "#call" do
    let(:invalid_body) { {get_habita_datos_response: {get_habita_datos_return: {datos_habitante: {}}}} }
    let(:valid_body) do
      {
        get_habita_datos_response: {
          get_habita_datos_return: {
            datos_habitante: {
              item: {
                fecha_nacimiento_string: "1-1-1980"
              }
            }
          }
        }
      }
    end

    it "returns the response for the first valid variant" do
      allow(api).to receive(:get_response_body).with(1, "00123456").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "123456").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "0123456").and_return(valid_body)

      response = api.call(1, "123456")

      expect(response).to be_valid
      expect(response.date_of_birth).to eq(Date.new(1980, 1, 1))
    end

    it "returns the last failed response" do
      allow(api).to receive(:get_response_body).with(1, "00123456").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "00123456s").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "00123456S").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "123456").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "123456s").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "123456S").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "0123456").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "0123456s").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "0123456S").and_return(invalid_body)
      response = api.call(1, "123456")

      expect(response).not_to be_valid
    end

    it "accepts response with array of items" do
      item_array = {get_habita_datos_response: {get_habita_datos_return: {datos_habitante: {item:[{whatever: ""},{nombre: "Marie", apellido1: "Curie"}] }}}}

      expect(api).to receive(:get_response_body).with(1, "123456").and_return(item_array)

      response = api.call(1, "123456")
      expect(response).to be_valid
      expect(response.name).to eq("Marie Curie")
    end
  end

  describe "Response" do
    describe "#date_of_birth" do
      def make_response_with_date(date_string)
        CensusApi::Response.new(get_habita_datos_response: {get_habita_datos_return: {datos_habitante: {item: {fecha_nacimiento_string: date_string}}}})
      end

      it "handles dates in yyyymmdd format as well as ddmmyyyy and even mmddyyyy" do
        expect(make_response_with_date("12-20-1980").date_of_birth).to eq(Date.new(1980, 12, 20))
        expect(make_response_with_date("20-12-1980").date_of_birth).to eq(Date.new(1980, 12, 20))
        expect(make_response_with_date("1980-12-20").date_of_birth).to eq(Date.new(1980, 12, 20))
      end

      it "handles bogus body dates without throwing an error" do
        expect(make_response_with_date("50").date_of_birth).to be_nil
        expect(make_response_with_date("1980").date_of_birth).to be_nil
        expect(make_response_with_date("potato").date_of_birth).to be_nil
      end
    end

    describe "#document_number" do
      def make_response_with_dni(number, letter)
        CensusApi::Response.new(get_habita_datos_response: {get_habita_datos_return: {datos_habitante: {item: {identificador_documento: number, letra_documento_string: letter}}}})
      end
      it "gets the number gluing the number and letter from the api" do
        expect(make_response_with_dni("12345678", "Z").document_number).to eq("12345678Z")
        expect(make_response_with_dni("66666666", "Q").document_number).to eq("66666666Q")
      end
    end
  end

end
