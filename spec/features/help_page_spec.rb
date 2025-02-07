require "rails_helper"

describe "Help page" do

  context "Index" do

    scenario "Help menu and page is visible if feature is enabled" do
      Setting["feature.help_page"] = true

      visit root_path

      expect(page).to have_link "Help"

      within("#navigation_bar") do
        click_link "Help"
      end

      expect(page).to have_content("Decide Madrid is the Madrid City Council's citizen
                                    participation platform")
    end

    scenario "Help menu and page is hidden if feature is disabled" do
      Setting["feature.help_page"] = nil

      visit root_path

      expect(page).not_to have_link "Help"
    end
  end
end
