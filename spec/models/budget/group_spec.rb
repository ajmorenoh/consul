require "rails_helper"

describe Budget::Group do
  it_behaves_like "sluggable", updatable_slug_trait: :drafting_budget

  describe "Validations" do

    let(:budget) { create(:budget) }
    let(:group) { create(:budget_group, budget: budget) }

    describe "name" do
      before do
        group.update(name: "object name")
      end

      it "can be repeatead in other budget's groups" do
        expect(build(:budget_group, budget: create(:budget), name: "object name")).to be_valid
      end

      it "may be repeated for the same group and a different locale" do
        group.update(name_fr: "object name")

        expect(group.translations.last).to be_valid
      end

      it "must not be repeated for a different group in any locale" do
        group.update(name_en: "English", name_es: "Español")

        expect(build(:budget_group, budget: budget, name_en: "English")).not_to be_valid
        expect(build(:budget_group, budget: budget, name_en: "Español")).not_to be_valid
      end
    end

    describe "max_supportable_headings" do
      it "is invalid if its not greater than 1" do
        group.max_supportable_headings = 0
        expect(group).not_to be_valid
      end
    end

    describe "max_votable_headings" do
      it "is invalid if its not greater than 1" do
        group.max_votable_headings = 0
        expect(group).not_to be_valid
      end
    end
  end

  describe "before_save action #strip_name" do
    it "doesn't create default translations" do
      group = create(:budget_group, name: "Group Name", budget: create(:budget))
      group.translations.destroy_all
      expect(group.translations.count).to be 0

      group.update(name_fr: "En Français")
      expect(group.translations.count).to eq(1)
    end

  end

  describe "#sort_by_name" do
    it "returns groups sorted by name ASC" do
      thinkers = create(:budget_group, name: "Mmmm...")
      sleepers = create(:budget_group, name: "Zzz...")
      startled = create(:budget_group, name: "Aaaaah!")

      expect(Budget::Group.sort_by_name).to eq [startled, thinkers, sleepers]
    end

    it "returns groups with multiple translations only once" do
      create(:budget_group, name_en: "English", name_es: "Spanish")

      expect(Budget::Group.sort_by_name.count).to eq 1
    end

    context "fallback locales" do
      before do
        allow(I18n.fallbacks).to receive(:[]).and_return([:es])
        Globalize.set_fallbacks_to_all_available_locales
      end

      it "orders by name considering fallback locale," do
        budget = create(:budget, name: "Teams")
        charlie = create(:budget_group, budget: budget, name: "Charlie")
        delta = create(:budget_group, budget: budget, name: "Delta")
        zulu = Globalize.with_locale(:es) do
          create(:budget_group, budget: budget, name: "Zulu", name_fr: "Alpha")
        end
        bravo = Globalize.with_locale(:es) do
          create(:budget_group, budget: budget, name: "Bravo")
        end

        expect(Budget::Group.sort_by_name.count).to eq 4
        expect(Budget::Group.sort_by_name).to eq [bravo, charlie, delta, zulu]
      end
    end
  end
end
