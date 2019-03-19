require "rails_helper"

describe GeozoneStats do
  let(:winterfell) { create(:geozone, name: "Winterfell") }
  let(:riverlands) { create(:geozone, name: "Riverlands") }

  describe "#name" do
    let(:stats) { GeozoneStats.new(winterfell, []) }

    it "returns the geozone name" do
      expect(stats.name).to eq "Winterfell"
    end
  end

  describe "#count" do
    before do
      2.times { create(:user, geozone: winterfell) }
      1.times { create(:user, geozone: riverlands) }
    end

    let(:winterfell_stats) { GeozoneStats.new(winterfell, User.all) }
    let(:riverlands_stats) { GeozoneStats.new(riverlands, User.all) }

    it "counts participants from the geozone" do
      expect(winterfell_stats.count).to eq 2
      expect(riverlands_stats.count).to eq 1
    end
  end

  describe "#percentage" do
    before do
      2.times { create(:user, geozone: winterfell) }
      1.times { create(:user, geozone: riverlands) }
    end

    let(:winterfell_stats) { GeozoneStats.new(winterfell, User.all) }
    let(:riverlands_stats) { GeozoneStats.new(riverlands, User.all) }

    it "calculates percentage relative to the amount of participants" do
      expect(winterfell_stats.percentage).to eq 66.667
      expect(riverlands_stats.percentage).to eq 33.333
    end
  end

  describe "#population_percentage" do
    context "geozone doesn't respond to population" do
      before { create(:user, geozone: winterfell) }
      let(:stats) { GeozoneStats.new(winterfell, []) }

      it "returns 0" do
        expect(stats.population_percentage).to eq 0.0
      end
    end

    context "geozone does not have population" do
      before do
        allow(winterfell).to receive(:population).and_return 0
        create(:user, geozone: winterfell)
      end

      let(:stats) { GeozoneStats.new(winterfell, []) }

      it "returns 0" do
        expect(stats.population_percentage).to eq 0.0
      end
    end

    context "geozone has population" do
      before do
        allow(winterfell).to receive(:population).and_return 100
        2.times { create(:user, geozone: winterfell) }
      end

      let(:stats) { GeozoneStats.new(winterfell, User.all) }

      it "returns the percentage of the geozone population which participated" do
        expect(stats.population_percentage).to eq 2.0
      end
    end
  end
end
