class Contact < ApplicationRecord
  SOURCES = %w[website instagram checkout referral import].freeze

  has_many :deliveries, dependent: :destroy
  has_many :campaigns, through: :deliveries

  validates :email, presence: true, uniqueness: { case_sensitive: false }

  scope :subscribed, -> { where(status: "subscribed") }
  scope :unsubscribed, -> { where(status: "unsubscribed") }
  scope :joined_since, ->(time) { where(subscribed_at: time..) }

  # Contacts with at least one open on or after `time`.
  scope :opened_since, ->(time) {
    where(id: Delivery.opened.where(opened_at: time..).select(:contact_id))
  }
  scope :not_opened_since, ->(time) {
    where.not(id: Delivery.opened.where(opened_at: time..).select(:contact_id))
  }

  scope :ever_opened, -> { where(id: Delivery.opened.select(:contact_id)) }
  scope :never_opened, -> { where.not(id: Delivery.opened.select(:contact_id)) }

  # Only judge someone as cold or disengaged once they have actually had a
  # fair chance to engage — otherwise last week's signups look like dead weight.
  scope :received_at_least, ->(n) {
    where(id: Delivery.delivered.group(:contact_id).having("COUNT(*) >= ?", n).select(:contact_id))
  }

  def name
    [ first_name, last_name ].compact_blank.join(" ").presence
  end

  def last_opened_at
    deliveries.opened.maximum(:opened_at)
  end
end
