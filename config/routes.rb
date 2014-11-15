Rails.application.routes.draw do
  resources :events
  resources :images

  devise_for :users, :controllers => { :registrations => "users/registrations" }

  mount Palantir::API => '/'
  root 'welcome#index'
end
