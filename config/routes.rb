Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  root "home#index"

  devise_scope :user do
    post 'users/guest_sign_in', to: 'users/sessions#guest_sign_in'
  end

  resources :books, only: [:new, :create]
  get '/books', to: 'books#search'

  resources :tasks do
    collection do
      get 'today'
    end

    resources :reads, only: [:new, :create, :destroy]
  end
end