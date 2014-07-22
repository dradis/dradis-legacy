Dradis::Frontend::Engine.routes.draw do

  # ----------------------------------------------------------------- Resources
  resources :categories
  # resources :configurations

  resources :issues

  resources :nodes do
    collection { post :sort }
    resources :evidence
    resources :notes
    constraints(:id => /.*/) do
      # resources :attachments
    end
  end


  # ------------------------------------------------------------ Upload Manager
  get '/upload' => 'upload#new', as: :upload_manager



  # ------------------------------------------------------------ Authentication
  # These routes allow users to set the shared password
  get '/setup' => 'sessions#init'
  post '/setup' => 'sessions#setup'

  # Authentication routes
  resource :session
  get '/login' => 'sessions#new', as: :login
  get '/logout' => 'sessions#destroy', as: :logout


  # --------------------------------------------------------------------- Debug

  if Rails.env.development?
    get '/info', to: 'home#info'
  end

  root to: 'home#index'
end