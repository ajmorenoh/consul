  def self.sort_by_delegated_ballots_and_price(spending_proposals, delegated_ballots)
    arr = spending_proposals.map do |sp|
      { sp: sp,
        ballots: sp.ballot_lines_count + (delegated_ballots[sp.id] || 0),
        price: sp.price }
    end
    arr.sort! do |a,b|
      ballots = b[:ballots] <=> a[:ballots]
      ballots != 0 ? ballots : b[:price] <=> a[:price]
    end
    arr.map{|h| h[:sp]}
  end
