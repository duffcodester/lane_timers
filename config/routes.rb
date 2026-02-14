Rails.application.routes.draw do
  resources :teams
  resources :bookings, only: [:create, :destroy]

  root "bookings#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
