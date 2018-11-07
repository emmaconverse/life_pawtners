Rails.application.routes.draw do
  devise_for :users do
    root to: "pets#new"
  end

  resources :favorites, only: [:index, :create]
  resources :pets
  root to: "pets#new"


  resources :posts
end
