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

  # The interface is the Vue SPA in frontend/. Rails serves JSON only.
  root to: proc { [ 200, { "Content-Type" => "application/json" }, [ { api: "/api/suggestions", spa: "http://localhost:5173" }.to_json ] ] }
end
