Dradis::Frontend::Engine.routes.draw do

  # ----------------------------------------------------------------- Resources
  resources :categories
  resources :configurations


  resources :issues

  resources :nodes do
    # collection { post :sort }
    member do
      get :tree
    end
    resources :evidence
    resources :notes

    # This deals with attachment extensions used as :format by Rails
    constraints(:id => /.*/) do
      resources :attachments
    end
  end


  # ----------------------------------------------------- Upload/Export Manager
  get  '/export' => 'export#index', as: :export_manager
  post '/export' => 'export#create'

  get  '/upload'        => 'upload#index',  as: :upload_manager
  post '/upload'        => 'upload#create'
  post '/upload/parse'  => 'upload#parse'
  get  '/upload/status' => 'upload#status'



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
