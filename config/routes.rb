Rails.application.routes.draw do
  get  "login",  to: "sessions#new",     as: :login
  post "login",  to: "sessions#create"
  get "logout", to: "sessions#destroy", as: :logout


  resources :clubs do
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

  get   "user/edit", to: "user#edit",   as: :edit_current_user
  patch "user/edit", to: "user#update", as: :update_current_user

  patch "settings/clubs_columns", to: "settings#update_clubs_columns", as: :clubs_columns_setting

  get "tools", to: "tools#index", as: :tools

  root "bookings#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
