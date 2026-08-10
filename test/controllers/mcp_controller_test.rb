require "test_helper"

class McpControllerTest < ActionDispatch::IntegrationTest
  def setup
    Delivery.delete_all
    Suggestion.delete_all
    Campaign.delete_all
    Contact.delete_all

    now = Time.current
    Contact.insert_all!(Array.new(45) do |i|
      { email: "joiner#{i}@example.com", status: "subscribed", source: "instagram",
        subscribed_at: 5.days.ago, created_at: now, updated_at: now }
    end)
    SuggestionGenerator.new.call
  end

  def rpc(method, params = nil, id: 1)
    body = { jsonrpc: "2.0", method: method }
    body[:id] = id unless id.nil?
    body[:params] = params if params
    post "/mcp", params: body.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    response.body.presence && JSON.parse(response.body)
  end

  def call_tool(name, args = {})
    rpc("tools/call", { name: name, arguments: args })&.dig("result")
  end

  def tool_text(result) = result.dig("content", 0, "text")

  def open_id
    Suggestion.open.in_category("new_subscribers").order(:variant).first.id
  end

  test "initialize echoes the protocol version the client asked for" do
    body = rpc("initialize", { protocolVersion: "2025-03-26" })

    assert_response :success
    assert_equal "2.0", body["jsonrpc"]
    assert_equal "2025-03-26", body.dig("result", "protocolVersion")
    assert_equal "nitrosend-suggested-campaigns", body.dig("result", "serverInfo", "name")
  end

  test "tools are advertised with schemas" do
    tools = rpc("tools/list").dig("result", "tools")

    assert_equal %w[nitro_suggest_campaigns nitro_dismiss_suggestion nitro_draft_campaign],
                 tools.map { |t| t["name"] }
    tools.each do |tool|
      assert tool["description"].present?
      assert_equal "object", tool.dig("inputSchema", "type")
    end
  end

  test "listing reports the audience, its rule and one angle" do
    text = tool_text(call_tool("nitro_suggest_campaigns"))

    assert_match "New subscribers (45 members)", text
    assert_match "Rule: Joined in the last 30 days.", text
    assert_match "45 people joined in the last 30 days", text
    assert_match "Held back for this audience", text,
      "alternatives must be visible, or the agent goes looking for them elsewhere"
  end

  test "exactly one angle is recommended, the rest are named but not expanded" do
    text = tool_text(call_tool("nitro_suggest_campaigns"))
    angles = Suggestion.in_category("new_subscribers").order(:variant)

    # Every angle is discoverable by title and id.
    angles.each { |a| assert_match a.title, text }

    # Only the recommendation is expanded, so there is still a single answer to
    # "what should I send", not three competing ones.
    expanded = angles.count { |a| text.include?(a.proposed_angle) }
    assert_equal 1, expanded, "only the recommended angle should be argued in full"
    assert_match "Suggestion ##{angles.first.id}", text
  end

  test "a held-back angle can be drafted directly, without dismissing down to it" do
    held = Suggestion.open.in_category("new_subscribers").order(:variant).second

    text = tool_text(call_tool("nitro_draft_campaign", { suggestion_id: held.id }))

    assert_match "Created draft campaign", text
    assert_equal "drafted", held.reload.status
    assert_equal 0, Suggestion.open.in_category("new_subscribers").count
  end

  test "dismissing promotes the next angle" do
    first = open_id
    text = tool_text(call_tool("nitro_dismiss_suggestion", { suggestion_id: first }))

    assert_match "Turned down", text
    assert_match "Next angle for New subscribers", text
    assert_equal "dismissed", Suggestion.find(first).status
  end

  test "an audience goes quiet once its angles are exhausted" do
    last = nil
    3.times { last = tool_text(call_tool("nitro_dismiss_suggestion", { suggestion_id: open_id })) }

    assert_match "has no angles left", last, "the final dismissal should say so"
    assert_match "Quiet: every angle was turned down",
                 tool_text(call_tool("nitro_suggest_campaigns"))
    assert_equal 0, Suggestion.open.in_category("new_subscribers").count
  end

  test "drafting creates a campaign and settles the audience" do
    text = tool_text(call_tool("nitro_draft_campaign", { suggestion_id: open_id }))

    assert_match "Created draft campaign", text
    assert_match "Nothing has been sent", text
    assert_equal 1, Campaign.where(status: "draft").count
    assert_equal 0, Suggestion.open.in_category("new_subscribers").count
    assert_match "Settled: a campaign is already drafted",
                 tool_text(call_tool("nitro_suggest_campaigns"))
  end

  test "drafting never claims a send, and points at the approval step" do
    text = tool_text(call_tool("nitro_draft_campaign", { suggestion_id: open_id }))

    assert_match "Status: draft", text
    assert_match "Nothing has been sent and nothing is scheduled", text
    assert_match "approval step", text
    assert_no_match(/\bsent successfully|has been sent\b(?! and nothing)/, text)
  end

  test "no tool on this server can send" do
    names = rpc("tools/list").dig("result", "tools").map { |t| t["name"] }

    assert_empty names.grep(/send|schedule|deliver/),
      "sending must stay a deliberate human step in Nitrosend"
  end

  test "acting on a suggestion twice is refused rather than duplicated" do
    id = open_id
    call_tool("nitro_draft_campaign", { suggestion_id: id })
    text = tool_text(call_tool("nitro_draft_campaign", { suggestion_id: id }))

    assert_match "already drafted", text
    assert_equal 1, Campaign.where(status: "draft").count
  end

  test "an unknown id is a tool error, not a crash" do
    result = call_tool("nitro_draft_campaign", { suggestion_id: 999_999 })

    assert_equal true, result["isError"]
    assert_match "No suggestion with that id", tool_text(result)
  end

  test "an unknown method returns method not found" do
    body = rpc("nonsense")

    assert_equal(-32601, body.dig("error", "code"))
  end

  test "notifications get no response body" do
    rpc("notifications/initialized", nil, id: nil)

    assert_response :accepted
    assert_empty response.body
  end

  test "the SSE stream is declined, since nothing is server initiated" do
    get "/mcp"

    assert_response :method_not_allowed
  end
end
