Rails.application.routes.draw do
  root to: 'home#index'

  get 'books', to: 'books#search'
end
