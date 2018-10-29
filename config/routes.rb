Rails.application.routes.draw do
  devise_for :users do
    root to: "home#index"
  end

  root to: "home#index"

  resources :home




end
