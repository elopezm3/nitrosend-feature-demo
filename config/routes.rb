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

  # Vue Router owns every other path, so deep links land on the SPA rather
  # than a Rails 404.
  get "*path", to: "spa#index", constraints: ->(req) {
    req.format.html? && !req.path.start_with?("/api", "/mcp", "/rails", "/spa/")
  }
end
