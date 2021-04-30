Rails.application.routes.draw do
  devise_for :users
  root to: 'home#index'

  resources :books, only: [:new, :create]
  get '/books', to: 'books#search'
end