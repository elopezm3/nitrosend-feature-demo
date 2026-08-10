# Seed data for Kestrel Supply Co., a fictional workwear brand.
#
# The engagement archetypes are shaped so every AudienceSegment lands populated.

RNG = Random.new(42) # deterministic: reseeding gives the same store every time

def rand_in(range)
  RNG.rand(range)
end

puts "Clearing existing data…"
Delivery.delete_all
Suggestion.delete_all
Campaign.delete_all
Contact.delete_all

# ---------------------------------------------------------------- campaigns --
# Spread across ~10 months. Five land inside the 90-day engagement window,
# which is what lets a loyal contact accumulate 3+ recent opens.
CAMPAIGNS = [
  [ 300, "Spring restock",              "The full spring range is back in stock", "promo" ],
  [ 275, "Field notes: March",         "Three things we learned resoling boots", "newsletter" ],
  [ 250, "The boot guide",              "Which Kestrel boot is actually for you", "editorial" ],
  [ 225, "Easter weekend: 20% off",    "Four days only, sitewide", "promo" ],
  [ 200, "Field notes: April",         "On waxed canvas, and why we gave up on nylon", "newsletter" ],
  [ 175, "New: the waxed canvas range", "Six new pieces, made in Adelaide", "product" ],
  [ 150, "Midyear clearance",           "Last sizes, last chance", "promo" ],
  [ 125, "Field notes: June",          "A short history of the work jacket", "newsletter" ],
  [ 100, "How we make our wool",        "From the Barossa, in eleven steps", "editorial" ],
  [  82, "Winter preview",              "First look at the cold weather range", "product" ],
  [  64, "Field notes: August",        "What we're reading this month", "newsletter" ],
  [  45, "Back in stock: the Ridgeline", "The one you kept asking about", "product" ],
  [  27, "Field notes: September",     "Repair, don't replace", "newsletter" ],
  [  12, "Autumn restock: early access", "Boots, canvas and wool, back in every size", "promo" ]
].freeze

puts "Creating #{CAMPAIGNS.size} sent campaigns…"
campaigns = CAMPAIGNS.map do |days_ago, name, preheader, kind|
  Campaign.create!(
    name: name,
    subject: name,
    preheader: preheader,
    status: "sent",
    audience_label: kind == "promo" ? "All subscribers" : "Newsletter",
    from_name: "Kestrel Supply Co.",
    from_email: "hello@kestrelsupply.com",
    sent_at: days_ago.days.ago
  )
end

Campaign.create!(
  name: "Workshop tour (draft)", subject: "Come see where it's made",
  preheader: "A short film from the Adelaide workshop", status: "draft",
  audience_label: "Newsletter", from_name: "Kestrel Supply Co.",
  from_email: "hello@kestrelsupply.com"
)

# Each archetype is a rule about *when* someone opens.
ARCHETYPES = {
  loyal:    { share: 0.12, joined: 180..540, opens: ->(age) { 0.85 } },
  casual:   { share: 0.30, joined:  90..540, opens: ->(age) { 0.30 } },
  slipping: { share: 0.14, joined: 200..540, opens: ->(age) { age > 60 ? 0.60 : 0.0 } },
  cold:     { share: 0.18, joined: 250..600, opens: ->(age) { age > 180 ? 0.50 : 0.0 } },
  never:    { share: 0.16, joined: 220..600, opens: ->(age) { 0.0 } },
  fresh:    { share: 0.10, joined:   1..29,  opens: ->(age) { 0.55 } }
}.freeze

FIRST = %w[Amelia Noah Priya Marcus Ingrid Tomas Rosa Dev Hana Leo Maren Felix
           Cora Jonas Sadie Otto Nadia Ellis Bea Kwame Lena Rafa Iris Soren
           Talia Hugo Mira Ansel Wren Callum].freeze
LAST  = %w[Achterberg Okonkwo Lindqvist Nakamura Oyelaran Castellanos Varga
           Brennan Dvorak Mwangi Salvatore Thorsdottir Whitlock Bergstrom
           Rahman Ferreira Novak Haddad Kirby Ashworth].freeze
DOMAINS = %w[gmail.com outlook.com proton.me hey.com fastmail.com icloud.com].freeze

TOTAL = 1_200
puts "Creating #{TOTAL} contacts…"

rows = []
assignments = []
index = 0

ARCHETYPES.each do |kind, spec|
  count = (TOTAL * spec[:share]).round
  count.times do
    index += 1
    first = FIRST.sample(random: RNG)
    last  = LAST.sample(random: RNG)
    joined = rand_in(spec[:joined]).days.ago

    # Instagram signups usually have no first name.
    source = Contact::SOURCES.sample(random: RNG)
    has_name = !(source == "instagram" && RNG.rand < 0.7)

    rows << {
      email: "#{first.downcase}.#{last.downcase.gsub(/[^a-z]/, '')}#{index}@#{DOMAINS.sample(random: RNG)}",
      first_name: has_name ? first : nil,
      last_name: has_name ? last : nil,
      source: source,
      status: RNG.rand < 0.04 ? "unsubscribed" : "subscribed",
      subscribed_at: joined,
      unsubscribed_at: nil,
      created_at: joined, updated_at: joined
    }
    assignments << kind
  end
end

Contact.insert_all!(rows)
contacts = Contact.order(:id).pluck(:id, :subscribed_at, :status)
puts "  #{contacts.size} contacts"

# ---------------------------------------------------------------- deliveries --
puts "Building deliveries…"
deliveries = []

contacts.each_with_index do |(contact_id, subscribed_at, status), i|
  spec = ARCHETYPES[assignments[i]]

  campaigns.each do |campaign|
    next if subscribed_at > campaign.sent_at            # not on the list yet
    next if status == "unsubscribed" && RNG.rand < 0.5  # left partway through

    age_in_days = ((Time.current - campaign.sent_at) / 1.day).round
    sent_at = campaign.sent_at + rand_in(0..90).minutes

    # insert_all! requires identical keys on every row.
    row = {
      campaign_id: campaign.id, contact_id: contact_id,
      delivered_at: sent_at, opened_at: nil, clicked_at: nil,
      bounced_at: nil, unsubscribed_at: nil,
      created_at: sent_at, updated_at: sent_at
    }

    if RNG.rand < 0.008                                  # hard bounce
      row[:delivered_at] = nil
      row[:bounced_at] = sent_at
    elsif RNG.rand < spec[:opens].call(age_in_days)
      row[:opened_at] = sent_at + rand_in(5..2_880).minutes
      row[:clicked_at] = row[:opened_at] + rand_in(1..60).minutes if RNG.rand < 0.28
      row[:unsubscribed_at] = row[:opened_at] if RNG.rand < 0.004
    end

    deliveries << row
  end
end

deliveries.each_slice(5_000) { |batch| Delivery.insert_all!(batch) }
puts "  #{Delivery.count} deliveries"

# ------------------------------------------------------------------- report --
puts "\nSegment populations:"
AudienceSegment.all.each do |segment|
  puts format("  %-16s %5d   %s", segment.key, segment.size, segment.definition)
end

puts "\nGenerating suggestions…"
created = SuggestionGenerator.new.call
puts "  #{created.size} suggestions across #{created.map(&:category).uniq.size} categories"
puts "\nDone. #{Contact.count} contacts, #{Campaign.count} campaigns, #{Delivery.count} deliveries."
