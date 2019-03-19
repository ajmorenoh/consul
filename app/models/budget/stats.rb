class Budget::Stats
  include Statisticable
  alias_method :budget, :resource

  def self.stats_methods
    super +
      %i[total_participants_support_phase total_participants_vote_phase
         total_budget_investments total_votes total_selected_investments
         total_unfeasible_investments headings]
  end

  def total_participants
    participants.distinct.count
  end

  def total_participants_support_phase
    voters.count
  end

  def total_participants_vote_phase
    balloters.count
  end

  def total_budget_investments
    budget.investments.count
  end

  def total_votes
    budget.ballots.pluck(:ballot_lines_count).inject(0) { |sum, x| sum + x }
  end

  def total_selected_investments
    budget.investments.selected.count
  end

  def total_unfeasible_investments
    budget.investments.unfeasible.count
  end

  def headings
    groups = Hash.new(0)
    budget.headings.order('id ASC').each do |heading|
      groups[heading.id] = Hash.new(0).merge(calculate_heading_totals(heading))
    end

    groups[:total] = Hash.new(0)
    groups[:total][:total_investments_count] = groups.collect {|_k, v| v[:total_investments_count]}.sum
    groups[:total][:total_participants_support_phase] = groups.collect {|_k, v| v[:total_participants_support_phase]}.sum
    groups[:total][:total_participants_vote_phase] = groups.collect {|_k, v| v[:total_participants_vote_phase]}.sum
    groups[:total][:total_participants_every_phase] = groups.collect {|_k, v| v[:total_participants_every_phase]}.sum

    budget.headings.each do |heading|
      groups[heading.id].merge!(calculate_heading_stats_with_totals(groups[heading.id], groups[:total], heading.population))
    end

    groups[:total][:percentage_participants_support_phase] = groups.collect {|_k, v| v[:percentage_participants_support_phase]}.sum
    groups[:total][:percentage_participants_vote_phase] = groups.collect {|_k, v| v[:percentage_participants_vote_phase]}.sum
    groups[:total][:percentage_participants_every_phase] = groups.collect {|_k, v| v[:percentage_participants_every_phase]}.sum

    groups
  end

  private

    def participants
      User.where(id: (authors + voters + balloters + poll_ballot_voters).uniq.compact)
    end

    def authors
      budget.investments.pluck(:author_id)
    end

    def voters
      supports(budget).distinct.pluck(:voter_id)
    end

    def balloters
      budget.ballots.where("ballot_lines_count > ?", 0).distinct.pluck(:user_id)
    end

    def poll_ballot_voters
      budget&.poll ? budget.poll.voters.pluck(:user_id) : []
    end

    def geozone_stats
      budget.headings.sort_by_name.map do |heading|
        GeozoneStats.new(heading, participants, voters_and_balloters_by_heading(heading))
      end
    end

    def balloters_by_heading(heading_id)
      stats_cache("balloters_by_heading_#{heading_id}") do
        budget.ballots.joins(:lines)
                      .where(budget_ballot_lines: { heading_id: heading_id} )
                      .distinct.pluck(:user_id)
      end
    end

    def voters_by_heading(heading)
      stats_cache("voters_by_heading_#{heading.id}") do
        supports(heading).distinct.pluck(:voter_id)
      end
    end

    def calculate_heading_totals(heading)
      {
        total_investments_count: heading.investments.count,
        total_participants_support_phase: voters_by_heading(heading).count,
        total_participants_vote_phase: balloters_by_heading(heading.id).count,
        total_participants_every_phase: voters_and_balloters_by_heading(heading).count
      }
    end

    def calculate_heading_stats_with_totals(heading_totals, groups_totals, population)
      {
        percentage_participants_support_phase: participants_percent(heading_totals, groups_totals, :total_participants_support_phase),
        percentage_district_population_support_phase: population_percent(population, heading_totals[:total_participants_support_phase]),
        percentage_participants_vote_phase: participants_percent(heading_totals, groups_totals, :total_participants_vote_phase),
        percentage_district_population_vote_phase: population_percent(population, heading_totals[:total_participants_vote_phase]),
        percentage_participants_every_phase: participants_percent(heading_totals, groups_totals, :total_participants_every_phase),
        percentage_district_population_every_phase: population_percent(population, heading_totals[:total_participants_every_phase])
      }
    end

    def voters_and_balloters_by_heading(heading)
      (voters_by_heading(heading) + balloters_by_heading(heading.id)).uniq
    end

    def participants_percent(heading_totals, groups_totals, phase)
      calculate_percentage(heading_totals[phase], groups_totals[phase])
    end

    def population_percent(population, participants)
      return 'N/A' unless population.to_f.positive?
      calculate_percentage(participants, population)
    end

    def supports(supportable)
      Vote.where(votable: supportable.investments)
    end

    stats_cache(*stats_methods)
    stats_cache :total_participants_with_gender
    stats_cache :voters, :participants, :authors, :balloters, :poll_ballot_voters

    def stats_cache(key, &block)
      Rails.cache.fetch("budgets_stats/#{budget.id}/#{key}/v14", &block)
    end
end
