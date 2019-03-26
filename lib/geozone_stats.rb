class GeozoneStats
  attr_reader :geozone, :participants

  def initialize(geozone, participants, geozone_participants = nil)
    @geozone = geozone
    @participants = participants
    @geozone_participants = geozone_participants
  end

  def geozone_participants
    @geozone_participants || participants.where(geozone: geozone)
  end

  def name
    geozone.name
  end

  def count
    geozone_participants.count
  end

  def percentage
    PercentageCalculator.calculate(count, participants.count)
  end

  def population_percentage
    if population_percentage?
      PercentageCalculator.calculate(count, geozone.population)
    else
      0.0
    end
  end

  def population_percentage?
    geozone.respond_to?(:population) && geozone.population > 0
  end
end
