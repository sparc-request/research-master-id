Rails.application.routes.draw do
  devise_for :users
  root 'research_masters#index'

  resources :research_masters

  resources :protocols do
    collection do
      match 'search' => 'protocols#search', via: [:get, :post], as: :search
    end
  end

  resources :primary_pis, only: [:index]
end
