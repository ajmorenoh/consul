require "rails_helper"

describe DuplicateSignaturesFinder do
  let(:finder) { DuplicateSignaturesFinder.new }
  let(:investment) { create :budget_investment }
  let(:sheet) { create :signature_sheet, signable: investment }
  let(:user) { create :user }

  describe "#all" do
    context "No signatures" do
      it "returns no signatures" do
        expect(finder.all).to be_empty
      end
    end

    context "No duplicates" do
      before do
        create :signature, signature_sheet: sheet, user: user
        create :signature, signature_sheet: sheet, user: create(:user)
        create :signature, signature_sheet: create(:signature_sheet), user: user
      end

      it "returns no signatures" do
        expect(finder.all).to be_empty
      end
    end

    context "One duplicate without votes" do
      let!(:first) { create :signature, signature_sheet: sheet, user: user }
      let!(:duplicate) { create :signature, signature_sheet: sheet, user: user }

      it "returns the duplicate but not the first signature" do
        expect(finder.all).not_to include first
        expect(finder.all).to eq [duplicate]
      end
    end

    context "Several duplicate records without votes" do
      let!(:first) { create :signature, signature_sheet: sheet, user: user }
      let!(:duplicate) { create :signature, signature_sheet: sheet, user: user }
      let!(:another_duplicate) { create :signature, signature_sheet: sheet, user: user }

      it "returns the duplicate records but not the first signature" do
        expect(finder.all).not_to include first
        expect(finder.all).to eq [duplicate, another_duplicate]
      end
    end

    context "One duplicate, one signature has a vote" do
      let!(:without_vote) { create :signature, signature_sheet: sheet, user: user }
      let!(:with_vote) { create :signature, signature_sheet: sheet, user: user }
      before do
        create(:vote, votable: investment, voter: user, signature: with_vote)
      end

      it "returns the signature without votes" do
        expect(finder.all).not_to include with_vote
        expect(finder.all).to eq [without_vote]
      end
    end

    context "Several duplicate records, one signature has a vote" do
      let!(:without_vote) { create :signature, signature_sheet: sheet, user: user }
      let!(:with_vote) { create :signature, signature_sheet: sheet, user: user }
      let!(:without_vote_either) { create :signature, signature_sheet: sheet, user: user }

      before do
        create(:vote, votable: investment, voter: user, signature: with_vote)
      end

      it "returns all signatures without votes" do
        expect(finder.all).not_to include with_vote
        expect(finder.all).to eq [without_vote, without_vote_either]
      end
    end

    context "Several duplicate records for several signatures" do
      let!(:first) { create :signature, signature_sheet: sheet, user: user }
      let!(:duplicate) { create :signature, signature_sheet: sheet, user: user }
      let!(:another_duplicate) { create :signature, signature_sheet: sheet, user: user }

      let(:another_user) { create :user }
      let!(:without_vote) { create :signature, signature_sheet: sheet, user: another_user }
      let!(:with_vote) { create :signature, signature_sheet: sheet, user: another_user }
      let!(:without_vote_either) { create :signature, signature_sheet: sheet, user: another_user }

      before do
        create(:vote, votable: investment, voter: another_user, signature: with_vote)
      end

      it "returns all duplicate signatures" do
        expect(finder.all).not_to include first
        expect(finder.all).not_to include with_vote

        expect(finder.all).to match_array([
          duplicate,
          another_duplicate,
          without_vote,
          without_vote_either
        ])
      end
    end
  end

  describe "#scope" do
    let(:finder) { DuplicateSignaturesFinder.new(Signature.where(signature_sheet: sheet)) }

    context "records in the scope" do
      let!(:first) { create :signature, signature_sheet: sheet, user: user }
      let!(:duplicate) { create :signature, signature_sheet: sheet, user: user }

      it "returns the duplicate signatures" do
        expect(finder.all).not_to include first
        expect(finder.all).to eq [duplicate]
      end
    end

    context "records not in the scope" do
      let(:another_sheet) { create :signature_sheet, signable: investment }
      before { 2.times { create :signature, signature_sheet: another_sheet, user: user } }

      it "ignores the duplicate signatures" do
        expect(finder.all).to be_empty
      end
    end
  end
end
