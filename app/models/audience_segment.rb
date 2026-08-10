# The audience definitions behind every suggestion on the AI suggested
# campaigns page.
#
# These live in one place on purpose. A suggestion is only trustworthy if the
# reader can check the claim underneath it, so each segment carries the plain
# English rule it applies and the page prints that rule next to the number.
# If a definition changes, it changes here and everywhere at once.
class AudienceSegment
  ENGAGED_WINDOW  = 90.days   # "recently active"
  SLIPPING_AFTER  = 60.days   # quiet long enough to notice
  COLD_AFTER      = 180.days  # quiet long enough to be a problem
  NEW_WINDOW      = 30.days   # still forming an impression
  FAIR_CHANCE     = 3         # emails received before we judge someone

  DEFINITIONS = [
    {
      key: "most_engaged",
      label: "Most engagement",
      definition: "Opened at least 3 campaigns in the last 90 days.",
      scope: -> { Contact.subscribed.where(id: engaged_contact_ids) }
    },
    {
      key: "new_subscribers",
      label: "New subscribers",
      definition: "Joined in the last 30 days.",
      scope: -> { Contact.subscribed.joined_since(NEW_WINDOW.ago) }
    },
    {
      key: "slipping",
      label: "Slipping away",
      definition: "Opened something in the last 180 days, but nothing in the last 60.",
      scope: -> {
        Contact.subscribed
               .opened_since(COLD_AFTER.ago)
               .not_opened_since(SLIPPING_AFTER.ago)
      }
    },
    {
      key: "cold_contacts",
      label: "Cold contacts",
      definition: "Has opened at some point, but nothing in the last 180 days.",
      scope: -> {
        Contact.subscribed
               .received_at_least(FAIR_CHANCE)
               .ever_opened
               .not_opened_since(COLD_AFTER.ago)
      }
    },
    {
      key: "never_opened",
      label: "Never opened",
      definition: "Received at least 3 campaigns and has never opened one.",
      scope: -> { Contact.subscribed.received_at_least(FAIR_CHANCE).never_opened }
    }
  ].freeze

  KEYS = DEFINITIONS.map { |d| d[:key] }.freeze

  attr_reader :key, :label, :definition

  def initialize(key:, label:, definition:, scope:)
    @key = key
    @label = label
    @definition = definition
    @scope = scope
  end

  def self.all
    @all ||= DEFINITIONS.map { |attrs| new(**attrs) }
  end

  def self.find(key)
    all.find { |segment| segment.key == key.to_s }
  end

  # Contacts with 3+ opens inside the engagement window. Extracted because the
  # HAVING clause does not compose with the other scopes cleanly.
  def self.engaged_contact_ids
    Delivery.opened
            .where(opened_at: ENGAGED_WINDOW.ago..)
            .group(:contact_id)
            .having("COUNT(*) >= ?", 3)
            .select(:contact_id)
  end

  def contacts
    AudienceSegment.instance_exec(&@scope)
  end

  def size
    @size ||= contacts.count
  end
end
