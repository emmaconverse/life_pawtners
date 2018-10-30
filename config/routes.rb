Rails.application.routes.draw do
  root to: "home#index"

  devise_for :users do
    root to: "home#index"
  end

  resources :posts

  get 'home/search'
  get 'home/new'

end
