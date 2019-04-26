class Poll
  class FinalRecount < ApplicationRecord

    VALID_ORIGINS = %w{ web booth letter }

    belongs_to :booth_assignment, class_name: "Poll::BoothAssignment"
    belongs_to :officer_assignment, class_name: "Poll::OfficerAssignment"

    validates :booth_assignment_id, presence: true
    validates :date, presence: true, uniqueness: {scope: :booth_assignment_id}
    validates :count, presence: true, numericality: {only_integer: true}
    validates :origin, inclusion: {in: VALID_ORIGINS}

    scope :web,    -> { where(origin: 'web') }
    scope :booth,  -> { where(origin: 'booth') }
    scope :letter, -> { where(origin: 'letter') }

    before_save :update_logs

    def update_logs
      if will_save_change_to_count? && count_in_database.present?
        self.count_log += ":#{count_in_database.to_s}"
        self.officer_assignment_id_log += ":#{officer_assignment_id_in_database.to_s}"
      end
    end
  end
end