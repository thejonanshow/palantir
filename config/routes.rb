Rails.application.routes.draw do
  devise_for :users
  mount Palantir::API => '/'
  root 'welcome#index'
end
