require "test_helper"

class SuggestionTest < ActiveSupport::TestCase
  def setup
    Delivery.delete_all
    Suggestion.delete_all
    Campaign.delete_all
    Contact.delete_all
  end

  def suggestion(variant: 0, status: "open")
    Suggestion.create!(
      category: "cold_contacts", variant: variant, status: status,
      title: "Angle #{variant}", headline_fact: "202 subscribers have gone quiet.",
      why_now: "They still count against your sending reputation.",
      proposed_subject: "Should we stop emailing you?",
      proposed_angle: "One honest last attempt.",
      estimated_reach: 202, confidence: "medium", generated_at: Time.current
    )
  end

  test "drafting creates a draft campaign that points back at its reasoning" do
    source = suggestion

    campaign = source.draft_campaign!

    assert_equal "draft", campaign.status
    assert_equal source.proposed_subject, campaign.subject
    assert_equal source.id, campaign.source_suggestion_id
    assert_match "Cold contacts", campaign.audience_label
    assert_equal "drafted", source.reload.status
  end

  test "drafting closes the audience by superseding the other angles" do
    chosen = suggestion(variant: 0)
    suggestion(variant: 1)
    suggestion(variant: 2)

    chosen.draft_campaign!

    assert_equal({ "drafted" => 1, "superseded" => 2 },
                 Suggestion.where(category: "cold_contacts").group(:status).count,
                 "deciding what to send an audience should stop it offering more ideas")
  end

  test "drafting leaves other audiences alone" do
    other = Suggestion.create!(
      category: "most_engaged", variant: 0, status: "open", title: "Untouched",
      headline_fact: "f", why_now: "w", proposed_subject: "s", proposed_angle: "a",
      estimated_reach: 194, confidence: "high", generated_at: Time.current
    )

    suggestion.draft_campaign!

    assert_equal "open", other.reload.status
  end


  test "a category outside the known audiences is rejected" do
    bogus = Suggestion.new(category: "made_up", title: "x")
    assert_not bogus.valid?
    assert_includes bogus.errors[:category].join, "included"
  end
end
