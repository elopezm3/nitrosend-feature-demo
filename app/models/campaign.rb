class Campaign < ApplicationRecord
  STATUSES = %w[draft scheduled sent].freeze

  has_many :deliveries, dependent: :destroy
  has_many :contacts, through: :deliveries

  validates :name, presence: true

  scope :sent, -> { where(status: "sent") }
  scope :drafts, -> { where(status: "draft") }
  scope :sent_since, ->(time) { sent.where(sent_at: time..) }
  scope :newest_first, -> { order(sent_at: :desc) }

  def delivered_count = deliveries.delivered.count
  def opened_count    = deliveries.opened.count
  def clicked_count   = deliveries.clicked.count

  def open_rate
    rate(opened_count, delivered_count)
  end

  def click_rate
    rate(clicked_count, delivered_count)
  end

  private

  def rate(part, whole)
    return 0.0 if whole.to_i.zero?
    (part.to_f / whole * 100).round(1)
  end
end
