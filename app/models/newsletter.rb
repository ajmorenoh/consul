class Newsletter < ApplicationRecord
  has_many :activities, as: :actionable

  validates :subject, presence: true
  validates :segment_recipient, presence: true
  validates :from, presence: true
  validates :body, presence: true
  validate :validate_segment_recipient

  validates_format_of :from, :with => /@/

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  def list_of_recipient_emails
    UserSegments.user_segment_emails(segment_recipient) if valid_segment_recipient?
  end

  def valid_segment_recipient?
    segment_recipient && UserSegments.respond_to?(segment_recipient)
  end

  def draft?
    sent_at.nil?
  end

  def deliver
    run_at = first_batch_run_at
    list_of_recipient_emails_in_batches.each do |recipient_emails|
      recipient_emails.each do |recipient_email|
        if valid_recipient?(recipient_email)
          Mailer.delay(run_at: run_at).newsletter(self, recipient_email)
          log_delivery(recipient_email)
        end
      end
      run_at += batch_interval
    end
  end

  def batch_size
    10000
  end

  def batch_interval
    40.minutes
  end

  def first_batch_run_at
    Time.current
  end

  def list_of_recipient_emails_in_batches
    list_of_recipient_emails.in_groups_of(batch_size, false)
  end

  private

  def validate_segment_recipient
    errors.add(:segment_recipient, :invalid) unless valid_segment_recipient?
  end

  def valid_recipient?(email)
    valid_email?(email) && pending_delivery?(email)
  end

  def valid_email?(email)
    email.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
  end

  def pending_delivery?(email)
    user = find_user(email)
    Activity.where(user: user, action: :email, actionable: self).blank?
  end

  def find_user(email)
    User.where(email: email).first
  end

  def log_delivery(email)
    user = find_user(email)
    Activity.log(user, :email, self)
  end

end
