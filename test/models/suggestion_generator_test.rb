require "test_helper"

class SuggestionGeneratorTest < ActiveSupport::TestCase
  def setup
    Delivery.delete_all
    Suggestion.delete_all
    Campaign.delete_all
    Contact.delete_all
  end

  # New subscribers is the cheapest audience to populate: joining recently is
  # the whole rule, so no delivery history is needed.
  def join(count, source: "instagram")
    now = Time.current
    rows = Array.new(count) do |i|
      { email: "joiner-#{SecureRandom.hex(4)}-#{i}@example.com", status: "subscribed",
        source: source, subscribed_at: 5.days.ago, created_at: now, updated_at: now }
    end
    Contact.insert_all!(rows)
  end

  def new_subscriber_suggestions
    Suggestion.where(category: "new_subscribers").order(:variant)
  end

  test "a qualifying audience gets every authored angle, strongest first" do
    join(45)

    SuggestionGenerator.new.call

    assert_equal 3, new_subscriber_suggestions.count
    assert_equal [ 0, 1, 2 ], new_subscriber_suggestions.map(&:variant)
    assert new_subscriber_suggestions.all? { |s| s.status == "open" }
  end

  test "an audience below the floor is not worth anyone's afternoon" do
    join(SuggestionGenerator::MIN_REACH - 1)

    SuggestionGenerator.new.call

    assert_equal 0, new_subscriber_suggestions.count
  end

  test "the headline fact carries the measured size, not a guess" do
    join(45)
    SuggestionGenerator.new.call

    assert_match "45 people joined", new_subscriber_suggestions.first.headline_fact
    assert_match "instagram", new_subscriber_suggestions.first.headline_fact
  end

  test "rebuilding refreshes the numbers on the angles still open" do
    join(45)
    SuggestionGenerator.new.call
    assert_match "45 people", new_subscriber_suggestions.first.headline_fact

    join(10)
    SuggestionGenerator.new.call

    assert_match "55 people", new_subscriber_suggestions.first.headline_fact
    assert_equal 55, new_subscriber_suggestions.first.estimated_reach
  end

  test "a rebuild does not resurrect an angle you turned down" do
    join(45)
    SuggestionGenerator.new.call
    rejected = new_subscriber_suggestions.first
    rejected.update!(status: "dismissed")

    SuggestionGenerator.new.call

    assert_equal "dismissed", rejected.reload.status
    assert_not new_subscriber_suggestions.where(status: "open", variant: rejected.variant).exists?,
      "dismissing has to mean something, including across an explicit rebuild"
    assert_equal 2, new_subscriber_suggestions.where(status: "open").count
  end

  test "a drafted audience stays closed after a rebuild" do
    join(45)
    SuggestionGenerator.new.call
    new_subscriber_suggestions.first.draft_campaign!

    SuggestionGenerator.new.call

    assert_equal 0, new_subscriber_suggestions.where(status: "open").count,
      "the audience already has a campaign, so it should not be offered more ideas"
    assert_equal 1, new_subscriber_suggestions.where(status: "drafted").count
    assert_equal 2, new_subscriber_suggestions.where(status: "superseded").count
  end

  test "no audience means no suggestions rather than invented ones" do
    assert_empty SuggestionGenerator.new.call
    assert_equal 0, Suggestion.count
  end

  test "every generated angle states a fact, a timing and a distinct subject" do
    join(45)
    SuggestionGenerator.new.call

    subjects = new_subscriber_suggestions.map(&:proposed_subject)
    assert_equal subjects.uniq.length, subjects.length, "angles must be genuinely different"

    new_subscriber_suggestions.each do |s|
      assert s.headline_fact.present?, "a suggestion without a number is an opinion"
      assert s.why_now.present?, "a suggestion that is true any week is not a daily brief item"
      assert_includes Suggestion::STATUSES, s.status
    end
  end
end
