INVESTMENT_IMAGE_FILES = %w[
  brennan-ehrhardt-25066-unsplash_713x513.jpg
  carl-nenzen-loven-381554-unsplash_713x475.jpg
  carlos-zurita-215387-unsplash_713x475.jpg
  hector-arguello-canals-79584-unsplash_713x475.jpg
  olesya-grichina-218176-unsplash_713x475.jpg
  sole-d-alessandro-340443-unsplash_713x475.jpg
].map do |filename|
  File.new(Rails.root.join("db",
                           "dev_seeds",
                           "images",
                           "budget",
                           "investments", filename))
end

def add_image_to(imageable)
  # imageable should respond to #title & #author
  imageable.image = Image.create!({
    imageable: imageable,
    title: imageable.title,
    attachment: INVESTMENT_IMAGE_FILES.sample,
    user: imageable.author
  })
  imageable.save
end

section "Creating Budgets" do
  finished_budget = Budget.create(
    name_en: "Budget for #{Date.current.year - 1}",
    name_es: "Presupuestos para #{Date.current.year - 1}",
    currency_symbol: "€",
    phase: "finished"
  )

  accepting_budget = Budget.create(
    name_en: "Budget for #{Date.current.year}",
    name_es: "Presupuestos para #{Date.current.year}",
    currency_symbol: "€",
    phase: "accepting"
  )

  Budget.find_each do |budget|
    budget.phases.each do |phase|
      random_locales.map do |locale|
        Globalize.with_locale(locale) do
          phase.description = "Description for locale #{locale}"
          phase.summary = "Summary for locale #{locale}"
          phase.save!
        end
      end
    end
  end

  Budget.all.each do |budget|
    city_group_params = {
      name_en: I18n.t("seeds.budgets.groups.all_city", locale: :en),
      name_es: I18n.t("seeds.budgets.groups.all_city", locale: :es)
    }
    city_group = budget.groups.create!(city_group_params)

    city_heading_params = {
      name_en: I18n.t("seeds.budgets.groups.all_city", locale: :en),
      name_es: I18n.t("seeds.budgets.groups.all_city", locale: :es),
      price: 1000000,
      population: 1000000,
      latitude: "40.416775",
      longitude: "-3.703790"
    }
    city_group.headings.create!(city_heading_params)

    districts_group_params = {
      name_en: I18n.t("seeds.budgets.groups.districts", locale: :en),
      name_es: I18n.t("seeds.budgets.groups.districts", locale: :es)
    }
    districts_group = budget.groups.create!(districts_group_params)

    north_heading_params = {
      name_en: I18n.t("seeds.geozones.north_district", locale: :en),
      name_es: I18n.t("seeds.geozones.north_district", locale: :es),
      price: rand(5..10) * 100000,
      population: 350000,
      latitude: "40.416775",
      longitude: "-3.703790"
    }
    districts_group.headings.create!(north_heading_params)

    west_heading_params = {
      name_en: I18n.t("seeds.geozones.west_district", locale: :en),
      name_es: I18n.t("seeds.geozones.west_district", locale: :es),
      price: rand(5..10) * 100000,
      population: 300000,
      latitude: "40.416775",
      longitude: "-3.703790"
    }
    districts_group.headings.create!(west_heading_params)

    east_heading_params = {
      name_en: I18n.t("seeds.geozones.east_district", locale: :en),
      name_es: I18n.t("seeds.geozones.east_district", locale: :es),
      price: rand(5..10) * 100000,
      population: 200000,
      latitude: "40.416775",
      longitude: "-3.703790"
    }
    districts_group.headings.create!(east_heading_params)

    central_heading_params = {
      name_en: I18n.t("seeds.geozones.central_district", locale: :en),
      name_es: I18n.t("seeds.geozones.central_district", locale: :es),
      price: rand(5..10) * 100000,
      population: 150000,
      latitude: "40.416775",
      longitude: "-3.703790"
    }
    districts_group.headings.create!(central_heading_params)
  end
end

section "Creating Investments" do
  tags = Faker::Lorem.words(10)
  100.times do
    heading = Budget::Heading.reorder("RANDOM()").first

    investment = Budget::Investment.create!(
      author: User.reorder("RANDOM()").first,
      heading: heading,
      group: heading.group,
      budget: heading.group.budget,
      title: Faker::Lorem.sentence(3).truncate(60),
      description: "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>",
      created_at: rand((Time.current - 1.week)..Time.current),
      feasibility: %w[undecided unfeasible feasible feasible feasible feasible].sample,
      unfeasibility_explanation: Faker::Lorem.paragraph,
      valuation_finished: [false, true].sample,
      tag_list: tags.sample(3).join(","),
      price: rand(1..100) * 100000,
      skip_map: "1",
      terms_of_service: "1"
    )

    add_image_to(investment) if Random.rand > 0.5
  end
end

section "Marking investments as visible to valuators" do
  (1..50).to_a.sample.times do
    Budget::Investment.reorder("RANDOM()").first.update(visible_to_valuators: true)
  end
end

section "Geolocating Investments" do
  Budget.find_each do |budget|
    budget.investments.each do |investment|
      MapLocation.create(latitude: Setting["map.latitude"].to_f + rand(-10..10)/100.to_f,
                         longitude: Setting["map.longitude"].to_f + rand(-10..10)/100.to_f,
                         zoom: Setting["map.zoom"],
                         investment_id: investment.id)
    end
  end
end

section "Balloting Investments" do
  Budget.finished.first.investments.last(20).each do |investment|
    investment.update(selected: true, feasibility: "feasible")
  end
end

section "Voting Investments" do
  not_org_users = User.where(["users.id NOT IN(?)", User.organizations.pluck(:id)])
  100.times do
    voter = not_org_users.level_two_or_three_verified.reorder("RANDOM()").first
    investment = Budget::Investment.reorder("RANDOM()").first
    investment.vote_by(voter: voter, vote: true)
  end
end

section "Balloting Investments" do
  100.times do
    budget = Budget.finished.reorder("RANDOM()").first
    ballot = Budget::Ballot.create(user: User.reorder("RANDOM()").first, budget: budget)
    ballot.add_investment(budget.investments.reorder("RANDOM()").first)
  end
end

section "Winner Investments" do
  budget = Budget.finished.first
  50.times do
    heading = budget.headings.all.sample
    investment = Budget::Investment.create!(
      author: User.all.sample,
      heading: heading,
      group: heading.group,
      budget: heading.group.budget,
      title: Faker::Lorem.sentence(3).truncate(60),
      description: "<p>#{Faker::Lorem.paragraphs.join("</p><p>")}</p>",
      created_at: rand((Time.current - 1.week)..Time.current),
      feasibility: "feasible",
      valuation_finished: true,
      selected: true,
      price: rand(10000..heading.price),
      skip_map: "1",
      terms_of_service: "1"
    )
    add_image_to(investment) if Random.rand > 0.3
  end
  budget.headings.each do |heading|
    Budget::Result.new(budget, heading).calculate_winners
  end
end

section "Creating Valuator Groups Assignments" do
  ValuatorGroup.create(name: I18n.t("seeds.budgets.valuator_groups.culture_and_sports"),
                       valuators: [Valuator.find(1), Valuator.find(2)])
  ValuatorGroup.create(name: I18n.t("seeds.budgets.valuator_groups.gender_and_diversity"),
                       valuators: [Valuator.find(3), Valuator.find(4)])
  ValuatorGroup.create(name: I18n.t("seeds.budgets.valuator_groups.urban_development"),
                       valuators: [Valuator.find(5), Valuator.find(6)])
  ValuatorGroup.create(name: I18n.t("seeds.budgets.valuator_groups.equity_and_employment"),
                       valuators: [Valuator.find(7), Valuator.find(8)])
end

section "Creating Valuation direct Assignments" do
  (1..50).to_a.sample.times do
    Budget::Investment.all.sample.valuators << Valuator.all.sample
  end
end

section "Creating Valuation Group Assignments" do
  (1..50).to_a.sample.times do
    Budget::Investment.all.sample.valuator_groups << ValuatorGroup.all.sample
  end
end

section "Marking investments as visible to valuators" do
  (1..50).to_a.sample.times do
    Budget::Investment.reorder("RANDOM()").first.update(visible_to_valuators: true)
  end
end
