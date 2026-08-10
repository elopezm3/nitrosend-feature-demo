class Suggestion < ApplicationRecord
  STATUSES = %w[open dismissed drafted superseded].freeze

  validates :category, inclusion: { in: AudienceSegment::KEYS }
  validates :title, presence: true

  scope :open,      -> { where(status: "open") }
  scope :dismissed, -> { where(status: "dismissed") }
  scope :in_category, ->(key) { where(category: key) }
  scope :strongest_first, -> { order(estimated_reach: :desc) }

  def segment
    AudienceSegment.find(category)
  end

  # Drafting also supersedes the audience's other angles: once you have decided
  # what to send these people, more ideas for the same people are noise.
  def draft_campaign!
    transaction do
      campaign = Campaign.create!(
        name: title,
        subject: proposed_subject,
        preheader: headline_fact.truncate(140),
        status: "draft",
        audience_label: "#{segment.label} (#{estimated_reach} contacts)",
        from_name: "Kestrel Supply Co.",
        from_email: "hello@kestrelsupply.com",
        source_suggestion_id: id
      )
      update!(status: "drafted")
      self.class.where(category: category, status: "open").update_all(status: "superseded")
      campaign
    end
  end

end
