Rails.application.routes.draw do
  resources :teams do
    get :export, on: :collection
  end
  resources :meet_sessions do
    post :duplicate, on: :member
  end
  delete "bookings/clear", to: "bookings#clear", as: :clear_bookings
  resources :bookings, only: [:create, :destroy, :update]

  patch "settings/teams_columns", to: "settings#update_teams_columns", as: :teams_columns_setting

  root "bookings#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
