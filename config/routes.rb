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

  root "spa#index"

  # Vue Router owns every other path, so deep links land on the SPA rather
  # than a Rails 404.
  get "*path", to: "spa#index", constraints: ->(req) {
    req.format.html? && !req.path.start_with?("/api", "/rails", "/spa/")
  }
end
