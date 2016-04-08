Rails.application.routes.draw do
  devise_for :identities
  root 'welcome#index'
end
