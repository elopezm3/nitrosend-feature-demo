# MCP server for the suggested campaigns feature, over JSON-RPC on POST /mcp.
#
# Connect with:
#   claude mcp add --transport http nitrosend-demo https://<host>/mcp
#
# Stateless: no session id is issued, so every request stands alone. The demo
# has no auth because there is nothing to protect, nothing sends, and the data
# resets on reseed.
class McpController < ActionController::API
  PROTOCOL_VERSION = "2025-06-18".freeze

  TOOLS = [
    {
      name: "nitro_suggest_campaigns",
      description: "List the campaigns worth sending today, grouped by audience. " \
                   "Each audience recommends one angle in full, and names its held-back " \
                   "alternatives by id and title so nothing is hidden from you. This is " \
                   "the complete set: there is no other source to consult, and no tool " \
                   "that returns more detail on a held-back angle. To act on one, " \
                   "dismiss the recommendation to promote it, or draft it directly by id.",
      inputSchema: { type: "object", properties: {}, additionalProperties: false }
    },
    {
      name: "nitro_dismiss_suggestion",
      description: "Turn down the recommended angle for an audience, promoting the " \
                   "next one in its place. Use this to reject an idea, not to browse: " \
                   "the alternatives are already listed by nitro_suggest_campaigns, and " \
                   "dismissing is permanent. When an audience runs out it goes quiet.",
      inputSchema: {
        type: "object",
        properties: {
          suggestion_id: { type: "integer", description: "id from nitro_suggest_campaigns" }
        },
        required: [ "suggestion_id" ],
        additionalProperties: false
      }
    },
    {
      name: "nitro_draft_campaign",
      description: "Accept an angle and create it as a draft campaign. Works on any " \
                   "angle id from nitro_suggest_campaigns, recommended or held back, so " \
                   "there is no need to dismiss your way down to one. This closes the " \
                   "audience: the remaining angles are withdrawn, because one campaign " \
                   "per audience is the point. Creates a draft only, nothing is sent.",
      inputSchema: {
        type: "object",
        properties: {
          suggestion_id: { type: "integer", description: "id from nitro_suggest_campaigns" }
        },
        required: [ "suggestion_id" ],
        additionalProperties: false
      }
    }
  ].freeze

  def handle
    id = params[:id]
    method = params[:method]

    # Notifications carry no id and expect no reply.
    return head :accepted if id.nil?

    case method
    when "initialize"  then reply(id, initialize_result)
    when "tools/list"  then reply(id, { tools: TOOLS })
    when "tools/call"  then reply(id, call_tool)
    when "ping"        then reply(id, {})
    else error(id, -32601, "Unknown method: #{method}")
    end
  rescue ActiveRecord::RecordNotFound
    reply(id, text("No suggestion with that id. Call nitro_suggest_campaigns for current ids.", failed: true))
  rescue StandardError => e
    error(id, -32603, e.message)
  end

  # The spec allows a server with no server-initiated messages to refuse the
  # SSE stream, which keeps this a plain request/response endpoint.
  def stream
    head :method_not_allowed
  end

  private

  def initialize_result
    {
      protocolVersion: params.dig(:params, :protocolVersion) || PROTOCOL_VERSION,
      capabilities: { tools: { listChanged: false } },
      serverInfo: { name: "nitrosend-suggested-campaigns", version: "0.1.0" }
    }
  end

  def call_tool
    name = params.dig(:params, :name)
    args = params.dig(:params, :arguments) || {}

    case name
    when "nitro_suggest_campaigns" then text(suggestions_report)
    when "nitro_dismiss_suggestion" then text(dismiss(args[:suggestion_id]))
    when "nitro_draft_campaign" then text(draft(args[:suggestion_id]))
    else text("Unknown tool: #{name}", failed: true)
    end
  end

  # ------------------------------------------------------------------ tools --

  def suggestions_report
    account = "Kestrel Supply Co., #{number(Contact.subscribed.count)} subscribed contacts, " \
              "#{Campaign.sent.count} campaigns sent."

    open_by_category = Suggestion.open.order(:variant).group_by(&:category)
    lines = []

    AudienceSegment.all.each do |segment|
      produced = Suggestion.in_category(segment.key)
      next if produced.none?

      available = Array(open_by_category[segment.key])
      current = available.first

      lines << ""
      lines << "#{segment.label} (#{number(segment.size)} members)"
      lines << "  Rule: #{segment.definition}"

      if current
        lines << "  Suggestion ##{current.id}: #{current.title}"
        lines << "  Found: #{current.headline_fact}"
        lines << "  Why now: #{current.why_now}"
        lines << "  Angle: #{current.proposed_angle}"
        lines << "  Subject: \"#{current.proposed_subject}\""
        lines << "  Confidence: #{current.confidence}"

        held = available.drop(1)
        if held.any?
          lines << "  Held back for this audience (draft any of these directly by id):"
          held.each { |h| lines << "    ##{h.id}: #{h.title} (#{h.confidence} confidence)" }
        end
      elsif produced.exists?(status: "drafted")
        lines << "  Settled: a campaign is already drafted for this audience."
      else
        lines << "  Quiet: every angle was turned down. Nothing worth sending here."
      end
    end

    return "#{account}\n\nNothing worth sending today." if lines.empty?

    "#{account}\n#{lines.join("\n")}\n\n" \
    "One angle per audience is recommended on purpose; the alternatives are named " \
    "above so you can weigh them. Drafting any angle closes its audience, because " \
    "one campaign per audience is the point."
  end

  def dismiss(id)
    suggestion = Suggestion.find(id)
    return "Suggestion #{id} is already #{suggestion.status}." unless suggestion.status == "open"

    suggestion.update!(status: "dismissed")
    nxt = Suggestion.open.in_category(suggestion.category).order(:variant).first

    if nxt
      "Turned down \"#{suggestion.title}\". Next angle for #{suggestion.segment.label} " \
      "is ##{nxt.id}: #{nxt.title}. Found: #{nxt.headline_fact}"
    else
      "Turned down \"#{suggestion.title}\". #{suggestion.segment.label} has no angles " \
      "left and is now quiet."
    end
  end

  def draft(id)
    suggestion = Suggestion.find(id)
    return "Suggestion #{id} is already #{suggestion.status}." unless suggestion.status == "open"

    campaign = suggestion.draft_campaign!

    "Created draft campaign ##{campaign.id}, \"#{campaign.name}\", subject " \
    "\"#{campaign.subject}\", audience #{campaign.audience_label}. Nothing has been sent. " \
    "#{suggestion.segment.label} is now settled and will not offer further angles."
  end

  # ------------------------------------------------------------- transport --

  def text(body, failed: false)
    { content: [ { type: "text", text: body } ], isError: failed }
  end

  def reply(id, result)
    render json: { jsonrpc: "2.0", id: id, result: result }
  end

  def error(id, code, message)
    render json: { jsonrpc: "2.0", id: id, error: { code: code, message: message } }
  end

  def number(value)
    ActiveSupport::NumberHelper.number_to_delimited(value)
  end
end
