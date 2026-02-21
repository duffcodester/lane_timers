Rails.application.routes.draw do
  get  "login",  to: "sessions#new",     as: :login
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout


  resources :teams do
    collection do
      get :export
      post :import
    end
  end
  resources :meet_sessions do
    post :duplicate, on: :member
  end
  delete "bookings/clear", to: "bookings#clear", as: :clear_bookings
  resources :bookings, only: [:create, :destroy, :update]

  resources :users, only: [:index, :new, :create, :destroy]

  patch "settings/teams_columns", to: "settings#update_teams_columns", as: :teams_columns_setting

  root "bookings#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
