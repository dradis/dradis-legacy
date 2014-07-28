Dradis::Frontend::Engine.routes.draw do

  # ----------------------------------------------------------------- Resources
  resources :categories
  # resources :configurations

  resources :issues

  resources :nodes do
    # collection { post :sort }

    resources :evidence
    resources :notes

    # This deals with attachment extensions used as :format by Rails
    constraints(:id => /.*/) do
      resources :attachments
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


  # ---------------------------------------------------------------------- Root
  get '/info',    to: 'home#info' if Rails.env.development?
  get '/markup',  to: 'home#markup', as: :markup
  get '/preview', to: 'home#textilize', as: :preview, defaults: {format: :json}

  root to: 'home#index'
end