Rails.application.routes.draw do
  get 'events/index'

  get 'events/show'

  get 'welcome/index'

  devise_for :users, :controllers => { :registrations => "users/registrations" }

  mount Palantir::API => '/'
  root 'welcome#index'
end
