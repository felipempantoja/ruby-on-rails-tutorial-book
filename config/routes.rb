# frozen_string_literal = true

Rails.application.routes.draw do
  resources :users
  resources :sessions, only: %i[index new create destroy]
  resources :microposts, only: %i[create destroy]

  root to: 'static_pages#home'

  get '/help', to: 'static_pages#help', as: 'help'
  get '/about', to: 'static_pages#about', as: 'about'
  get '/contact', to: 'static_pages#contact', as: 'contact'

  get '/signup', to: 'users#new', as: 'signup'
  get '/signin', to: 'sessions#new', as: 'signin'
  delete '/signout', to: 'sessions#destroy', as: 'signout'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
