Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resources :suggestions, only: [ :index ] do
      member { patch :dismiss }
      collection { post :regenerate }
    end
  end

  # The interface is the Vue SPA in frontend/ — `npm run dev` on :5173, which
  # proxies /api here. Rails serves JSON only.
  root to: proc { [ 200, { "Content-Type" => "application/json" }, [ { api: "/api/suggestions", spa: "http://localhost:5173" }.to_json ] ] }
end
