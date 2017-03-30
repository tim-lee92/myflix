Myflix::Application.routes.draw do
  root to: 'pages#front'
  get 'ui(/:action)', controller: 'ui'

  get '/home', to: 'videos#home', as: 'home'
  get '/videos/search', to: 'videos#search'
  get '/videos/:id', to: 'videos#details'
  post '/videos/:video_id/reviews/create', to: 'reviews#create', as: 'video_reviews'
  get 'register', to: 'users#new'
  get 'sign_in', to: 'sessions#new', as: 'sign_in'
  get 'sign_out', to: 'sessions#destroy'
  get 'my_queue', to: 'queue_items#index'
  resources :categories, only: [:show]
  resources :users, only: [:create]
  resources :sessions, only: [:create]
  resources :queue_items, only: [:create, :destroy]
end
