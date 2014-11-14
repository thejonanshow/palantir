Rails.application.routes.draw do
  get 'welcome/index'

  devise_for :users, :controllers => { :registrations => "users/registrations" }

  mount Palantir::API => '/'
  root 'welcome#index'
end
