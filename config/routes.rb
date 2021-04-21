Rails.application.routes.draw do
  devise_for :users
  root to: 'home#index'

  get 'books', to: 'books#search'
end
