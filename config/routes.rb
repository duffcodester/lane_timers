Rails.application.routes.draw do
  get  "login",  to: "sessions#new",     as: :login
  post "login",  to: "sessions#create"
  get "logout", to: "sessions#destroy", as: :logout


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
  resources :bookings, only: [:create, :edit, :update, :destroy] do
    collection do
      get :list
    end
  end

  resources :users, only: [:index, :new, :create, :destroy]
  resources :meets

  patch "settings/teams_columns", to: "settings#update_teams_columns", as: :teams_columns_setting

  root "bookings#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
