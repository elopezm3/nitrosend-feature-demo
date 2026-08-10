class Suggestion < ApplicationRecord
  STATUSES = %w[open dismissed drafted].freeze

  validates :category, inclusion: { in: AudienceSegment::KEYS }
  validates :title, presence: true

  scope :open,      -> { where(status: "open") }
  scope :dismissed, -> { where(status: "dismissed") }
  scope :in_category, ->(key) { where(category: key) }
  scope :strongest_first, -> { order(estimated_reach: :desc) }

  def segment
    AudienceSegment.find(category)
  end

  # What gets handed to the agent when someone accepts a suggestion. The page
  # never writes the email itself — it writes the prompt and shows it first.
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
