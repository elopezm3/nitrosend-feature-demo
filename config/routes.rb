Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resources :suggestions, only: [ :index ] do
      member do
        patch :dismiss
        patch :restore
        post :draft
      end
      collection { post :regenerate }
    end

    resources :campaigns, only: [ :show ]
  end

  # MCP server. Clients POST JSON-RPC here; GET is the optional SSE stream,
  # which this server does not need.
  post "mcp" => "mcp#handle"
  get  "mcp" => "mcp#stream"

  root "spa#index"

  # Vue Router owns every other path, so deep links land on the SPA rather than
  # a Rails 404. Matching on path rather than on Accept: an unqualified */*
  # resolves to Mime::ALL, whose html? is false, so curl and anything else not
  # asking for HTML explicitly used to 404 on every deep link. Paths that look
  # like files are left alone so a missing asset still fails as a missing asset.
  get "*path", to: "spa#index", format: false, constraints: ->(req) {
    !req.path.start_with?("/api", "/mcp", "/rails", "/spa/") &&
      !req.path.match?(/\.\w{1,8}\z/)
  }
end
