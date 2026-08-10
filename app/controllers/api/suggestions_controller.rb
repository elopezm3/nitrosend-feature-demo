module Api
  class SuggestionsController < BaseController
    def index
      render json: {
        account: account_payload,
        categories: category_payloads
      }
    end

    def dismiss
      suggestion = Suggestion.find(params[:id])
      suggestion.update!(status: "dismissed")
      head :no_content
    end

    def regenerate
      SuggestionGenerator.new.call
      index
    end

    private

    def account_payload
      last = Campaign.sent.newest_first.first
      {
        brand: "Kestrel Supply Co.",
        list_size: Contact.subscribed.count,
        campaigns_sent: Campaign.sent.count,
        generated_at: Suggestion.open.maximum(:generated_at),
        last_send: last && {
          name: last.name,
          sent_at: last.sent_at,
          open_rate: last.open_rate
        }
      }
    end

    def category_payloads
      grouped = Suggestion.open.strongest_first.group_by(&:category)

      AudienceSegment.all.map do |segment|
        {
          key: segment.key,
          label: segment.label,
          definition: segment.definition,
          size: segment.size,
          suggestions: Array(grouped[segment.key]).map { |s| suggestion_payload(s) }
        }
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
