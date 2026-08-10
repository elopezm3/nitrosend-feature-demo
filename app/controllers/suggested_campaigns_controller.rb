class SuggestedCampaignsController < ApplicationController
  def index
    @suggestions = Suggestion.open.strongest_first.group_by(&:category)
    @segments = AudienceSegment.all
    @list_size = Contact.subscribed.count
    @last_send = Campaign.sent.newest_first.first
    @generated_at = Suggestion.open.maximum(:generated_at)
  end

  def dismiss
    suggestion = Suggestion.find(params[:id])
    suggestion.update!(status: "dismissed")
    redirect_to suggested_campaigns_path, notice: "Dismissed “#{suggestion.title}”."
  end

  def regenerate
    SuggestionGenerator.new.call
    redirect_to suggested_campaigns_path, notice: "Suggestions rebuilt from current data."
  end
end
