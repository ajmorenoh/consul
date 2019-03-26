namespace :spending_proposals do

  desc "Migrates Existing 2016 Spending Proposals to Budget Investments (PARTIALLY)"
  task migrate_to_budgets: :environment do
    puts "We have #{SpendingProposal.count} spending proposals"
    puts "Migrating!!..."
    SpendingProposal.find_each { |sp| MigrateSpendingProposalsToInvestments.new.import(sp) }
    puts "And now we've got #{Budget.where(name: '2016').first.investments.count} budgets"
  end

  desc "Migrates all necessary data from spending proposals to budget investments"
  task migrate: [
    "spending_proposals:pre_migrate",
    "spending_proposals:migrate_attributes",
    "spending_proposals:migrate_votes",
    "spending_proposals:migrate_ballots",
    "spending_proposals:post_migrate",
  ]

  desc "Run the required actions before the migration"
  task pre_migrate: :environment do
    require "migrations/spending_proposal/budget"

    puts "Starting pre rake tasks"
    Migrations::SpendingProposal::Budget.new.pre_rake_tasks
    puts "Finished"
  end

  desc "Migrates spending proposals attributes to budget investments attributes"
  task migrate_attributes: :environment do
    require "migrations/spending_proposal/budget_investments"

    puts "Starting to migrate attributes"
    Migrations::SpendingProposal::BudgetInvestments.new.update_all
    puts "Finished"
  end

  desc "Migrates spending proposl votes to budget investment votes"
  task migrate_votes: :environment do
    require "migrations/spending_proposal/vote"

    puts "Starting to migrate votes"
    Migrations::SpendingProposal::Vote.new.create_budget_investment_votes
    puts "Finished"
  end

  desc "Migrates spending proposals ballots to budget investments ballots"
  task migrate_ballots: :environment do
    require "migrations/spending_proposal/ballots"

    puts "Starting to migrate ballots"
    Migrations::SpendingProposal::Ballots.new.migrate_all
    puts "Finished"
  end

  desc "Run the required actions after the migration"
  task post_migrate: :environment do
    require "migrations/spending_proposal/budget"

    puts "Starting post rake tasks"
    Migrations::SpendingProposal::Budget.new.post_rake_tasks
    puts "Finished"
  end

end
