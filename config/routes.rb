Rails.application.routes.draw do
  resources :teams
  delete "bookings/clear", to: "bookings#clear", as: :clear_bookings
  resources :bookings, only: [:create, :destroy, :update]

  root "bookings#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
