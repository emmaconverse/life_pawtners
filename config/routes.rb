Rails.application.routes.draw do
  devise_for :users do
    root to: "pets#new"
  end

  resources :favorites, only: [:index, :create, :destroy]
  resources :pets, except: [:show, :delete]
  root to: "pets#new"


  resources :posts
end
