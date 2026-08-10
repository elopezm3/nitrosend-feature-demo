# Builds the campaign suggestions shown on the AI suggested campaigns page.
#
# Two rules shape everything here:
#
#   1. Every suggestion carries a fact the reader can go and check. Not
#      "consider a win-back" but "412 people have not opened anything since
#      March". A suggestion without a number is an opinion.
#
#   2. A thin segment produces no suggestion at all. A page that always has
#      something to say is a slot machine, and the empty state is a real
#      answer — sometimes the right move is to send nothing.
class SuggestionGenerator
  MIN_REACH = 40      # below this, a campaign is not worth anyone's afternoon
  SNOOZE = 14.days    # how long "not this one" keeps a category quiet

  def call
    Suggestion.where(status: "open").delete_all

    AudienceSegment.all.filter_map { |segment| build_for(segment) }
  end

  private

  def build_for(segment)
    return if segment.size < MIN_REACH
    return if recently_dismissed?(segment.key)

    attrs = case segment.key
    when "most_engaged"    then most_engaged(segment)
    when "new_subscribers" then new_subscribers(segment)
    when "slipping"        then slipping(segment)
    when "cold_contacts"   then cold_contacts(segment)
    when "never_opened"    then never_opened(segment)
    end
    return if attrs.blank?

    Suggestion.create!(
      category: segment.key,
      estimated_reach: segment.size,
      status: "open",
      generated_at: Time.current,
      **attrs
    )
  end

  # ------------------------------------------------------------- categories --

  def most_engaged(segment)
    best = best_recent_campaign
    {
      title: "Give your best readers something first",
      headline_fact: "#{segment.size} people have opened 3 or more campaigns in " \
                     "the last 90 days — #{share_of_list(segment.size)} of your list, " \
                     "opening at roughly #{engaged_open_rate}%.",
      why_now: best ? "#{best.name} was your strongest recent send at " \
                      "#{best.open_rate}% open rate, #{days_since(best.sent_at)} days ago. " \
                      "This group is warm right now." :
                      "This group is warm right now.",
      proposed_subject: "First look, because you always open these",
      proposed_angle: "Early or exclusive access rather than another discount. " \
                      "This group already opens; the job is to reward that, not " \
                      "to win it back.",
      confidence: "high"
    }
  end

  def new_subscribers(segment)
    top = top_source(segment)
    {
      title: "Introduce yourself to the people who just arrived",
      headline_fact: "#{segment.size} people joined in the last 30 days" +
                     (top ? ", most of them through #{top}." : "."),
      why_now: "They signed up recently and have seen at most " \
               "#{campaigns_since(30.days.ago)} of your campaigns. First " \
               "impressions are still forming.",
      proposed_subject: "Start here",
      proposed_angle: "An orientation, not a sale. What you make, why, and " \
                      "what they should expect to receive from you.",
      confidence: "high"
    }
  end

  def slipping(segment)
    {
      title: "Catch the ones going quiet, before they go cold",
      headline_fact: "#{segment.size} people opened something in the last 180 " \
                     "days but nothing in the last 60.",
      why_now: "They are still reachable. Once the gap passes 180 days, " \
               "win-back open rates fall off sharply — this is the cheaper " \
               "moment to act.",
      proposed_subject: "Did we lose you somewhere?",
      proposed_angle: "Acknowledge the gap plainly and offer a preference " \
                      "choice — fewer emails, or a different topic. Cutting " \
                      "frequency keeps more people than pretending nothing changed.",
      confidence: "high"
    }
  end

  def cold_contacts(segment)
    {
      title: "Decide what to do about the ones who stopped",
      headline_fact: "#{segment.size} subscribers have opened in the past but " \
                     "nothing in the last 180 days.",
      why_now: "They are still counted in every send, and consistently mailing " \
               "people who never open is what drags inbox placement down for " \
               "everyone else.",
      proposed_subject: "Should we stop emailing you?",
      proposed_angle: "One honest last attempt, then suppress the ones who do " \
                      "not respond. The point of this campaign is to earn the " \
                      "right to remove them.",
      confidence: "medium"
    }
  end

  def never_opened(segment)
    avg = average_received(segment)
    {
      title: "Test whether it is the subject lines",
      headline_fact: "#{segment.size} subscribers have received an average of " \
                     "#{avg} campaigns and opened none of them.",
      why_now: "They opted in, so the intent was real. Before suppressing " \
               "them, it is worth one send that looks nothing like the others.",
      proposed_subject: "A different kind of email",
      proposed_angle: "Plain text from a person, no template, no images. If a " \
                      "stripped-back send does not move them, the problem is " \
                      "the address, not the copy.",
      confidence: "low"
    }
  end

  # Dismissing a suggestion has to mean something. Without this, rebuilding
  # immediately resurrects whatever you just turned down.
  def recently_dismissed?(key)
    Suggestion.dismissed.in_category(key).where(updated_at: SNOOZE.ago..).exists?
  end

  # ------------------------------------------------------------------ facts --

  def list_size
    @list_size ||= Contact.subscribed.count
  end

  def share_of_list(n)
    return "—" if list_size.zero?
    "#{(n.to_f / list_size * 100).round}%"
  end

  def best_recent_campaign
    @best_recent_campaign ||= Campaign.sent_since(90.days.ago)
                                      .max_by { |campaign| campaign.open_rate }
  end

  def engaged_open_rate
    ids = AudienceSegment.engaged_contact_ids
    scope = Delivery.where(contact_id: ids).where(delivered_at: 90.days.ago..)
    delivered = scope.delivered.count
    return 0 if delivered.zero?
    (scope.opened.count.to_f / delivered * 100).round
  end

  def top_source(segment)
    segment.contacts.group(:source).count.max_by { |_, count| count }&.first
  end

  def campaigns_since(time)
    Campaign.sent_since(time).count
  end

  def average_received(segment)
    ids = segment.contacts.select(:id)
    total = Delivery.delivered.where(contact_id: ids).count
    people = segment.size
    people.zero? ? 0 : (total.to_f / people).round
  end

  def days_since(time)
    ((Time.current - time) / 1.day).round
  end
end
