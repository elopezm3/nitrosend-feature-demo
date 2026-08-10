require "test_helper"

# The segment definitions are the claim the whole feature rests on. Every
# suggestion says "255 people did X", so if these scopes are wrong the page is
# confidently wrong, which is worse than being empty.
class AudienceSegmentTest < ActiveSupport::TestCase
  def setup
    Delivery.delete_all
    Suggestion.delete_all
    Campaign.delete_all
    Contact.delete_all
  end

  # Sends `contact` a campaign `days_ago`, opened or not.
  def send_to(contact, days_ago:, opened: false)
    campaign = Campaign.create!(name: "Campaign #{days_ago}", status: "sent",
                                sent_at: days_ago.days.ago)
    Delivery.create!(campaign: campaign, contact: contact,
                     delivered_at: days_ago.days.ago,
                     opened_at: opened ? days_ago.days.ago : nil)
  end

  def contact(joined: 300, status: "subscribed")
    Contact.create!(email: "c#{SecureRandom.hex(4)}@example.com",
                    status: status, subscribed_at: joined.days.ago)
  end

  def keys_containing(person)
    AudienceSegment.all.select { |s| s.contacts.exists?(person.id) }.map(&:key)
  end

  test "most engaged needs three opens inside the window, not two" do
    keen = contact
    3.times { |i| send_to(keen, days_ago: 10 + i, opened: true) }

    nearly = contact
    2.times { |i| send_to(nearly, days_ago: 10 + i, opened: true) }

    assert_includes keys_containing(keen), "most_engaged"
    assert_not_includes keys_containing(nearly), "most_engaged"
  end

  test "opens outside the ninety day window do not count towards engagement" do
    stale = contact
    3.times { |i| send_to(stale, days_ago: 120 + i, opened: true) }

    assert_not_includes keys_containing(stale), "most_engaged"
  end

  test "slipping means quiet for sixty days but active within a hundred and eighty" do
    slipping = contact
    send_to(slipping, days_ago: 100, opened: true)

    still_active = contact
    send_to(still_active, days_ago: 100, opened: true)
    send_to(still_active, days_ago: 10, opened: true)

    assert_includes keys_containing(slipping), "slipping"
    assert_not_includes keys_containing(still_active), "slipping"
  end

  test "cold means it has opened before but not for a hundred and eighty days" do
    cold = contact(joined: 400)
    send_to(cold, days_ago: 300, opened: true)
    send_to(cold, days_ago: 280, opened: false)
    send_to(cold, days_ago: 260, opened: false)

    assert_includes keys_containing(cold), "cold_contacts"
    assert_not_includes keys_containing(cold), "never_opened"
  end

  test "never opened requires a fair chance of three delivered campaigns" do
    ignored = contact(joined: 400)
    3.times { |i| send_to(ignored, days_ago: 200 + i, opened: false) }

    barely_mailed = contact(joined: 400)
    2.times { |i| send_to(barely_mailed, days_ago: 200 + i, opened: false) }

    assert_includes keys_containing(ignored), "never_opened"
    assert_not_includes keys_containing(barely_mailed), "never_opened",
      "two campaigns is not enough of a chance to judge someone on"
  end

  test "new subscribers is about joining recently, not about engagement" do
    fresh = contact(joined: 5)
    assert_includes keys_containing(fresh), "new_subscribers"

    established = contact(joined: 200)
    assert_not_includes keys_containing(established), "new_subscribers"
  end

  test "unsubscribed people are never in any audience" do
    gone = contact(joined: 400, status: "unsubscribed")
    3.times { |i| send_to(gone, days_ago: 200 + i, opened: false) }

    assert_empty keys_containing(gone)
  end

  test "size reflects the data now, not the first time it was asked" do
    segment = AudienceSegment.find("new_subscribers")
    assert_equal 0, segment.size

    contact(joined: 2)

    # A fresh lookup must see the new contact. Caching the instances at class
    # level would freeze these counts for the life of the process.
    assert_equal 1, AudienceSegment.find("new_subscribers").size
  end

  test "every definition is exposed and findable by key" do
    assert_equal AudienceSegment::KEYS.sort, AudienceSegment.all.map(&:key).sort
    AudienceSegment::KEYS.each do |key|
      assert AudienceSegment.find(key).definition.present?, "#{key} needs a stated rule"
    end
  end
end
