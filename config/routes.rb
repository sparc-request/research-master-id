Rails.application.routes.draw do
  devise_for :users
  root 'research_masters#index'

  resources :research_masters do
    resources :associated_records, only: [:destroy]
  end
  match 'about' => 'research_masters#about', via: [:get], as: :about

  namespace :api do
    resources :research_masters, only: [:index, :show]
    resources :api_keys, only: [:create, :new]
  end

  resources :protocols do
    collection do
      match 'search' => 'protocols#search', via: [:get, :post], as: :search
    end
  end

  resources :primary_pis, only: [:index]
end
