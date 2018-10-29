Rails.application.routes.draw do
  get 'results/index'
  get 'results/show'
  devise_for :users do
    root to: "home#index"
  end

  root to: "home#index"

  resources :home




end
