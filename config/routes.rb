Rails.application.routes.draw do
  get 'welcome/index'

  devise_for :users
  mount Palantir::API => '/'
  root 'welcome#index'
end
