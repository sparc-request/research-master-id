Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  root 'research_masters#index'

  resources :research_masters

  resource :detail, only: [:show]

  get "test_exception_notifier" => "application#test_exception_notifier"

  namespace :api do
    resources :research_masters, only: [:index, :show]
    resources :validated_records, only: [:index]
    resources :api_keys, only: [:create, :new]
  end

  resource :directories, only: [:show]

  resources :protocols do
    collection do
      match 'search' => 'protocols#search', via: [:get, :post], as: :search
    end
  end

  resources :primary_pis, only: [:index]
end
