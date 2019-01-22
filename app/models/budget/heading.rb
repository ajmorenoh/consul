class Budget
  class Heading < ActiveRecord::Base
    OSM_DISTRICT_LEVEL_ZOOM = 12.freeze

    include Sluggable

    translates :name, touch: true
    include Globalizable

    belongs_to :group

    has_many :investments
    has_many :content_blocks

    validates_translation :name, presence: true
    validates :group_id, presence: true
    validates :price, presence: true
    validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/
    validates :population, numericality: { greater_than: 0 }, allow_nil: true
    validates :latitude, length: { maximum: 22 }, allow_blank: true, \
              format: /\A(-|\+)?([1-8]?\d(?:\.\d{1,})?|90(?:\.0{1,6})?)\z/
    validates :longitude, length: { maximum: 22 }, allow_blank: true, \
              format: /\A(-|\+)?((?:1[0-7]|[1-9])?\d(?:\.\d{1,})?|180(?:\.0{1,})?)\z/

    validate :name_uniqueness_by_budget

    delegate :budget, :budget_id, to: :group, allow_nil: true

    scope :order_by_group_name, -> do
      includes(:translations)
        .joins(group: :translations)
        .order("budget_group_translations.name DESC", "budget_heading_translations.name")
    end
    scope :allow_custom_content, -> do
      includes(:translations).where(allow_custom_content: true).order(:name)
    end

    def name_scoped_by_group
      group.single_heading_group? ? name : "#{group.name}: #{name}"
    end

    def to_param
      slug
    end

    def name_uniqueness_by_budget
      if group.budget.headings.includes(:translations).where(name: name).where.not(id: id).any?
        errors.add(:name, I18n.t("errors.messages.taken"))
      end
    end

    def can_be_deleted?
      investments.empty?
    end

    def city_heading?
      name == "Toda la ciudad"
    end

    private

    def generate_slug?
      slug.nil? || budget.drafting?
    end

  end
end
