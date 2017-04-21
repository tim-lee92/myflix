Myflix::Application.routes.draw do
  root to: 'pages#front'
  get 'ui(/:action)', controller: 'ui'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  mount StripeEvent::Engine => '/stripe_events'

  get '/home', to: 'videos#home', as: 'home'
  get '/videos/search', to: 'videos#search'
  get '/videos/advanced_search', to: 'videos#advanced_search'
  get '/videos/:id', to: 'videos#details', as: 'video'
  post '/videos/:video_id/reviews/create', to: 'reviews#create', as: 'video_reviews'
  get 'register', to: 'users#new'
  get 'register/:token', to: 'users#new_with_invitation_token', as: 'register_with_token'

  get 'sign_in', to: 'sessions#new', as: 'sign_in'
  get 'sign_out', to: 'sessions#destroy'
  get 'my_queue', to: 'queue_items#index'

  resources :categories, only: [:show]

  resources :users, only: [:create, :show]
  get 'people', to: 'relationships#index'
  resources :relationships, only: [:create, :destroy]

  resources :sessions, only: [:create]
  resources :queue_items, only: [:create, :destroy]
  post 'update_queue', to: 'queue_items#update_queue'

  get 'forgot_passwords', to: 'forgot_passwords#new'
  resources :forgot_passwords, only: [:create]
  get 'forgot_password_confirmation', to: 'forgot_passwords#confirm'

  resources :password_resets, only: [:show, :create]
  get 'expired_token', to: 'pages#expired_token'

  resources :invitations, only: [:new, :create]

  namespace :admin do
    resources :videos, only: [:new, :create]
    resources :payments, only: [:index]
  end
end
