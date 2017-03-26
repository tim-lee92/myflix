Myflix::Application.routes.draw do
  root to: 'pages#front'
  get 'ui(/:action)', controller: 'ui'

  get '/home', to: 'video#home'
  get '/videos/search', to: 'videos#search'
  get '/videos/:title', to: 'videos#details'
  get 'register', to: 'users#new'
  resources :users, only: [:create]
end
