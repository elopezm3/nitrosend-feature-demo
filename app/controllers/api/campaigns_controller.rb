module Api
  class CampaignsController < BaseController
    def show
      campaign = Campaign.find(params[:id])
      source = Suggestion.find_by(id: campaign.source_suggestion_id)

      render json: {
        id: campaign.id,
        name: campaign.name,
        subject: campaign.subject,
        preheader: campaign.preheader,
        status: campaign.status,
        audience_label: campaign.audience_label,
        from_name: campaign.from_name,
        from_email: campaign.from_email,
        created_at: campaign.created_at,
        source: source && { id: source.id, title: source.title, why_now: source.why_now }
      }
    end
  end
end
