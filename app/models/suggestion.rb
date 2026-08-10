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

  # Accepting a suggestion creates a real draft campaign and records where it
  # came from, so the campaign can always be traced back to the reasoning that
  # produced it.
  #
  # Drafting also closes the audience. Once you have decided what to send these
  # people, offering two more ideas for the same people is the feature arguing
  # with itself: the whole point is not over-suggesting, and a second campaign
  # to the same segment this week is exactly the fatigue it warns about.
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

  # What gets handed to the agent when someone accepts a suggestion. The page
  # never writes the email itself, it writes the prompt and shows it first.
  def agent_prompt
    <<~PROMPT.strip
      Draft a campaign for the "#{segment.label}" audience (#{estimated_reach} contacts).

      Angle: #{proposed_angle}
      Suggested subject: #{proposed_subject}

      Context: #{headline_fact}
      Timing: #{why_now}
    PROMPT
  end
end
