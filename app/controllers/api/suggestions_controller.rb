module Api
  class SuggestionsController < BaseController
    def index
      render json: payload
    end

    def dismiss
      Suggestion.find(params[:id]).update!(status: "dismissed")
      render json: payload
    end

    def restore
      Suggestion.find(params[:id]).update!(status: "open")
      render json: payload
    end

    def draft
      campaign = Suggestion.find(params[:id]).draft_campaign!
      render json: { campaign_id: campaign.id }, status: :created
    end

    def regenerate
      SuggestionGenerator.new.call
      render json: payload
    end

    private

    def payload
      { account: account_payload, categories: category_payloads, dismissed: dismissed_payload }
    end

    def account_payload
      last = Campaign.sent.newest_first.first
      {
        brand: "Kestrel Supply Co.",
        list_size: Contact.subscribed.count,
        campaigns_sent: Campaign.sent.count,
        generated_at: Suggestion.open.maximum(:generated_at),
        last_send: last && { name: last.name, sent_at: last.sent_at, open_rate: last.open_rate }
      }
    end

    # One angle is shown per audience at a time. Turning it down promotes the
    # next one, so a category only falls silent once its alternatives are
    # genuinely exhausted rather than the moment you reject an idea.
    #
    # An exhausted audience keeps its heading, its count and its rule. Running
    # out of advice for 202 people is not the same as those 202 people ceasing
    # to exist, and a section that vanishes says the wrong one.
    def category_payloads
      all = Suggestion.order(:variant).group_by(&:category)

      AudienceSegment.all.filter_map do |segment|
        produced = Array(all[segment.key])
        available = produced.select { |s| s.status == "open" }
        current = available.first

        # Never produced anything and too small to, so it has nothing to say.
        next if produced.empty?

        {
          key: segment.key,
          label: segment.label,
          definition: segment.definition,
          size: segment.size,
          state: current ? "active" : "exhausted",
          remaining: [ available.size - 1, 0 ].max,
          considered: produced.size,
          drafted: produced.count { |s| s.status == "drafted" },
          suggestions: current ? [ suggestion_payload(current) ] : []
        }
      end
    end

    # Dismissed suggestions are returned so the page can show what it is
    # holding back. Suppression the reader cannot see is just a bug.
    def dismissed_payload
      Suggestion.dismissed.map do |suggestion|
        { id: suggestion.id, title: suggestion.title, label: suggestion.segment.label }
      end
    end

    def suggestion_payload(suggestion)
      {
        id: suggestion.id,
        title: suggestion.title,
        headline_fact: suggestion.headline_fact,
        why_now: suggestion.why_now,
        proposed_subject: suggestion.proposed_subject,
        proposed_angle: suggestion.proposed_angle,
        estimated_reach: suggestion.estimated_reach,
        confidence: suggestion.confidence,
        agent_prompt: suggestion.agent_prompt
      }
    end
  end
end
