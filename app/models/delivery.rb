class Delivery < ApplicationRecord
  belongs_to :campaign
  belongs_to :contact

  scope :delivered,   -> { where.not(delivered_at: nil).where(bounced_at: nil) }
  scope :opened,      -> { where.not(opened_at: nil) }
  scope :clicked,     -> { where.not(clicked_at: nil) }
  scope :bounced,     -> { where.not(bounced_at: nil) }
  scope :unsubscribed, -> { where.not(unsubscribed_at: nil) }
end
