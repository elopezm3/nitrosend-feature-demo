# Builds the campaign suggestions shown on the AI suggested campaigns page.
#
# Three rules shape everything here:
#
#   1. Every suggestion carries a fact the reader can go and check. Not
#      "consider a win-back" but "412 people have not opened anything since
#      March". A suggestion without a number is an opinion.
#
#   2. A thin segment produces no suggestion at all. A page that always has
#      something to say is a slot machine, and the empty state is a real
#      answer. Sometimes the right move is to send nothing.
#
#   3. Every audience gets several genuinely different angles, not one idea
#      dressed three ways. Turning one down should offer a real alternative,
#      which is only true if the alternatives were actually different
#      campaigns to begin with.
#
# What is computed and what is written: the numbers are measured live from
# contacts and deliveries. The copy is authored here, one block per angle.
# This is a rules engine with real facts interpolated, not a model. The seam
# where a model would take over is Suggestion#agent_prompt, which already
# carries everything such a call would need.
class SuggestionGenerator
  MIN_REACH = 40 # below this, a campaign is not worth anyone's afternoon

  def call
    # Rebuilding refreshes the numbers on live suggestions but must not undo a
    # decision. Anything already dismissed or drafted stays that way.
    settled = Suggestion.where.not(status: "open").pluck(:category, :variant).to_set
    Suggestion.where(status: "open").delete_all

    AudienceSegment.all.flat_map { |segment| build_for(segment, settled) }
  end

  private

  def build_for(segment, settled)
    return [] if segment.size < MIN_REACH

    angles = send(segment.key, segment)

    angles.each_with_index.filter_map do |attrs, variant|
      next if settled.include?([ segment.key, variant ])

      Suggestion.create!(
        category: segment.key,
        variant: variant,
        estimated_reach: segment.size,
        status: "open",
        generated_at: Time.current,
        **attrs
      )
    end
  end

  # ------------------------------------------------------------- categories --
  # Each method returns the angles for that audience, strongest first.

  def most_engaged(segment)
    best = best_recent_campaign
    fact = "#{segment.size} people have opened 3 or more campaigns in the last " \
           "90 days, #{share_of_list(segment.size)} of your list, opening at " \
           "roughly #{engaged_open_rate}%."
    warm = best ? "#{best.name} was your strongest recent send at #{best.open_rate}% " \
                  "open rate, #{days_since(best.sent_at)} days ago. This group is warm right now." :
                  "This group is warm right now."

    [
      {
        title: "Give your best readers something first",
        headline_fact: fact,
        why_now: warm,
        proposed_subject: "First look, because you always open these",
        proposed_angle: "Early or exclusive access rather than another discount. " \
                        "This group already opens; the job is to reward that, not to win it back.",
        confidence: "high"
      },
      {
        title: "Ask them what they want to see next",
        headline_fact: fact,
        why_now: "These are the only people who reliably reply, so this is the " \
                 "cheapest research you will ever run. Everything you learn " \
                 "improves what you send to the other #{share_of_list(list_size - segment.size)}.",
        proposed_subject: "Two questions, thirty seconds",
        proposed_angle: "A short survey with a genuinely small number of " \
                        "questions. Say what you will do with the answers, and " \
                        "follow up publicly when you do.",
        confidence: "medium"
      },
      {
        title: "Ask your best readers to bring someone",
        headline_fact: fact,
        why_now: "Referrals only work when the asker already likes you. This " \
                 "is the one group where that is measurably true.",
        proposed_subject: "Know someone who would like this?",
        proposed_angle: "A referral ask with something worth passing on, not a " \
                        "discount code. Make the thing being shared the reward.",
        confidence: "low"
      }
    ]
  end

  def new_subscribers(segment)
    top = top_source(segment)
    fact = "#{segment.size} people joined in the last 30 days" +
           (top ? ", most of them through #{top}." : ".")
    seen = "They signed up recently and have seen at most " \
           "#{campaigns_since(30.days.ago)} of your campaigns. First impressions " \
           "are still forming."

    [
      {
        title: "Introduce yourself to the people who just arrived",
        headline_fact: fact,
        why_now: seen,
        proposed_subject: "Start here",
        proposed_angle: "An orientation, not a sale. What you make, why, and " \
                        "what they should expect to receive from you.",
        confidence: "high"
      },
      {
        title: "Lead with the one thing you are known for",
        headline_fact: fact,
        why_now: "#{seen} A new subscriber who does not yet know what you are " \
                 "best at will judge you on whatever arrives first.",
        proposed_subject: "The one we are known for",
        proposed_angle: "One product or one story, told properly, instead of a " \
                        "catalogue. Depth converts new readers better than breadth.",
        confidence: "medium"
      },
      {
        title: "Find out what brought them here",
        headline_fact: fact,
        why_now: "Everything you learn now can segment every send they receive " \
                 "afterwards. Asked later, the same question feels like you " \
                 "were not paying attention.",
        proposed_subject: "What are you here for?",
        proposed_angle: "A one-click preference capture with two or three " \
                        "options. Tag on click, then actually use the tags.",
        confidence: "medium"
      }
    ]
  end

  def slipping(segment)
    fact = "#{segment.size} people opened something in the last 180 days but " \
           "nothing in the last 60."

    [
      {
        title: "Catch the ones going quiet, before they go cold",
        headline_fact: fact,
        why_now: "They are still reachable. Once the gap passes 180 days, " \
                 "win-back open rates fall off sharply, so this is the cheaper " \
                 "moment to act.",
        proposed_subject: "Did we lose you somewhere?",
        proposed_angle: "Acknowledge the gap plainly and offer a preference " \
                        "choice: fewer emails, or a different topic. Cutting " \
                        "frequency keeps more people than pretending nothing changed.",
        confidence: "high"
      },
      {
        title: "Send them what they missed",
        headline_fact: fact,
        why_now: "They stopped opening partway through, so the last two months " \
                 "of your best work is genuinely new to them. Nobody else on " \
                 "your list can be sent a greatest hits email honestly.",
        proposed_subject: "In case you missed these",
        proposed_angle: "A short recap of your strongest recent sends, chosen " \
                        "by open rate rather than by what you liked writing.",
        confidence: "medium"
      },
      {
        title: "Offer less mail instead of losing them",
        headline_fact: fact,
        why_now: "Going quiet usually means the volume stopped fitting, not " \
                 "that the interest died. A downgrade is a much smaller ask " \
                 "than a re-subscribe later.",
        proposed_subject: "Want these less often?",
        proposed_angle: "A monthly digest option. Moving someone to a lower " \
                        "cadence keeps a reachable address instead of trading " \
                        "it for an unsubscribe.",
        confidence: "medium"
      }
    ]
  end

  def cold_contacts(segment)
    fact = "#{segment.size} subscribers have opened in the past but nothing in " \
           "the last 180 days."
    cost = "They are still counted in every send, and consistently mailing " \
           "people who never open is what drags inbox placement down for " \
           "everyone else."

    [
      {
        title: "Decide what to do about the ones who stopped",
        headline_fact: fact,
        why_now: cost,
        proposed_subject: "Should we stop emailing you?",
        proposed_angle: "One honest last attempt, then suppress the ones who " \
                        "do not respond. The point of this campaign is to earn " \
                        "the right to remove them.",
        confidence: "medium"
      },
      {
        title: "Make leaving easy and see who stays",
        headline_fact: fact,
        why_now: "#{cost} A clean exit now costs you far less than a spam " \
                 "complaint in six months.",
        proposed_subject: "One click to keep these coming",
        proposed_angle: "Invert the default: they stay only if they act. " \
                        "Smaller list, dramatically better deliverability, and " \
                        "no ambiguity about consent.",
        confidence: "high"
      },
      {
        title: "Change the format completely before giving up",
        headline_fact: fact,
        why_now: "Everything they have ignored looked the same. Before " \
                 "suppressing the address, it is worth one send that shares " \
                 "none of those signals.",
        proposed_subject: "Last one, unless you say otherwise",
        proposed_angle: "No template, no images, no tracking pixel styling. A " \
                        "short note that reads as though a person typed it.",
        confidence: "low"
      }
    ]
  end

  def never_opened(segment)
    avg = average_received(segment)
    fact = "#{segment.size} subscribers have received an average of #{avg} " \
           "campaigns and opened none of them."

    [
      {
        title: "Test whether it is the subject lines",
        headline_fact: fact,
        why_now: "They opted in, so the intent was real. Before suppressing " \
                 "them, it is worth one send that looks nothing like the others.",
        proposed_subject: "A different kind of email",
        proposed_angle: "Plain text from a person, no template, no images. If a " \
                        "stripped back send does not move them, the problem is " \
                        "the address, not the copy.",
        confidence: "low"
      },
      {
        title: "Check whether these addresses are real",
        headline_fact: fact,
        why_now: "#{avg} campaigns with zero opens is closer to a data problem " \
                 "than a content problem. Typos and role addresses do not open " \
                 "anything, ever.",
        proposed_subject: "Confirm your address",
        proposed_angle: "Validate before you spend more creative on them. A " \
                        "confirmation send doubles as list hygiene and tells " \
                        "you which addresses were never going to work.",
        confidence: "medium"
      },
      {
        title: "Try a completely different send time",
        headline_fact: fact,
        why_now: "Every campaign they have received went out on your usual " \
                 "schedule. If that schedule never suited them, the copy was " \
                 "never the variable being tested.",
        proposed_subject: "Morning, for once",
        proposed_angle: "Same list, deliberately unusual send window. Cheap to " \
                        "run and it isolates timing from content.",
        confidence: "low"
      }
    ]
  end

  # ------------------------------------------------------------------ facts --

  def list_size
    @list_size ||= Contact.subscribed.count
  end

  def share_of_list(n)
    return "an unknown share" if list_size.zero?
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
