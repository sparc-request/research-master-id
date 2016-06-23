Rails.application.routes.draw do
  devise_for :users
  root 'research_masters#index'

  resources :research_masters
end
