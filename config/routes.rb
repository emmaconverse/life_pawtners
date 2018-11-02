Rails.application.routes.draw do
  resources :homes
  root to: "homes#new"

  devise_for :users do
    root to: "homes#new"
  end

  resources :posts
end
