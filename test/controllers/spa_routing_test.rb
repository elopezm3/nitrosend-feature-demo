require "test_helper"

class SpaRoutingTest < ActionDispatch::IntegrationTest
  # Deep links must reach the SPA regardless of what the client asks for. An
  # unqualified Accept: */* resolves to Mime::ALL, whose html? is false, so
  # matching on format used to 404 for anything that was not a browser.
  test "deep links reach the SPA whatever the client accepts" do
    [ "/", "/learning", "/campaigns/1", "/anything/at/all" ].each do |path|
      get path, headers: { "HTTP_ACCEPT" => "*/*" }
      assert_response :success, "#{path} should serve the SPA for Accept: */*"

      get path, headers: { "HTTP_ACCEPT" => "text/html" }
      assert_response :success, "#{path} should serve the SPA for Accept: text/html"
    end
  end

  test "the API is not swallowed by the catch-all" do
    get "/api/suggestions", headers: { "HTTP_ACCEPT" => "*/*" }

    assert_response :success
    assert_equal "application/json", response.media_type
  end

  test "a missing file still fails as a missing file" do
    get "/nope.js"
    assert_response :not_found

    get "/spa/gone.css"
    assert_response :not_found
  end

  test "MCP is reachable and not treated as an SPA route" do
    post "/mcp",
         params: { jsonrpc: "2.0", id: 1, method: "tools/list" }.to_json,
         headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :success
    assert_equal "application/json", response.media_type
  end
end
