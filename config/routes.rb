Rails.application.routes.draw do
  devise_for :users
  root "home#index"

  resources :books, only: [:new, :create]
  get '/books', to: 'books#search'

  resources :tasks do
    resources :reads, except: [:index, :show]
  end
end