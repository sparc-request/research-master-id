Rails.application.routes.draw do
  devise_for :users
  root 'research_masters#index'

  resources :research_masters

  resources :pi_names, only: [:index]
end
