Dradis::Frontend::Engine.routes.draw do
  resources :categories
  # resources :configurations

  resources :nodes do
    collection { post :sort }
    resources :notes
    constraints(:id => /.*/) do
      # resources :attachments
    end
  end

  resource :session

  get '/login' => 'sessions#new', as: :login
  get '/logout' => 'sessions#destroy', as: :logout
  # These routes allow users to set the shared password
  get '/setup' => 'sessions#init'
  post '/setup' => 'sessions#setup'

  root to: 'home#index'
end