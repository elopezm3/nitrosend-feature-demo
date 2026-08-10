Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :suggested_campaigns, only: [ :index ], path: "suggested-campaigns" do
    member { patch :dismiss }
    collection { post :regenerate }
  end

  root "suggested_campaigns#index"
end
