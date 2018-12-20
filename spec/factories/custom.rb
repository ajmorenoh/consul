FactoryBot.define do
  factory :poll_nvote, class: 'Poll::Nvote' do
    user
    poll
  end

  factory :poll_ballot_sheet, class: 'Poll::BallotSheet' do
    association :poll
    association :officer_assignment, factory: :poll_officer_assignment
    data "1234;9876;5678\n1000;2000;3000;9999"
  end

  factory :poll_ballot, class: 'Poll::Ballot' do
    association :ballot_sheet, factory: :poll_ballot_sheet
    data "1,2,3"
  end

  factory :forum do
    sequence(:name) { |n| "Forum #{n}" }
    user
  end

  factory :represented_user, class: 'User' do
    association :representative, factory: :forum

    sequence(:username) { |n| "Represented#{n}" }
    sequence(:email)    { |n| "represented#{n}@consul.dev" }

    password            'vote_delegated'
    terms_of_service    '1'
    verified_at { Time.current }
    document_type "1"
    document_number
  end

  factory :ballot do
    user
  end

  factory :ballot_line do
    ballot
    spending_proposal { build(:spending_proposal, feasible: true) }
  end

  factory :volunteer_poll do
    sequence(:email)      { |n| "volunteer#{n}@consul.dev" }
    sequence(:first_name) { |n| "volunteer#{n} first name" }
    sequence(:last_name)  { |n| "volunteer#{n} last name" }
    sequence(:document_number) { |n| "12345#{n}" }
    sequence(:phone)      { |n| "6061111#{n}" }
    turns "3 turnos"
  end

  factory :probe do
    sequence(:codename) { |n| "probe_#{n}" }
  end

  factory :probe_option do
    probe
    sequence(:name) { |n| "Probe option #{n}" }
    sequence(:code) { |n| "probe_option_#{n}" }
  end
end
