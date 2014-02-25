Dradis::Core::Engine.add_routes do
  # Session management
  get '/setup' => 'sessions#init'
  post '/setup' => 'sessions#setup'
  get '/login' => 'sessions#new', :as => :login
  get '/logout' => 'sessions#destroy', :as => :logout

  # # Helper routes
  # get '/logs' => 'logs#index'
  # post '/preview' => 'home#preview'
  # 
  # # Resources
  # resources :categories
  # resources :nodes do
  #   collection { post :sort }
  #   resources :notes do
  #     resources :attachments
  #   end
  # end
  # resource :session
  # 
  # # Plugins
  # resources :plugins, :only => [:index]
  # # get '/export/' => 'export#list'
  # # get  '/import/'        => 'import#list'
  # # post '/import/filters' => 'import#filters'
  # # post '/import/search'  => 'import#search'
  # 
  root :to => 'home#index'
  # 
  # # Dradis 2.x routes
  # # -----------------
  # # resources :configurations
  # # resources :feeds
  # # 
  # # resources :nodes do
  # #   collection { post :sort }
  # #   resources :notes
  # #   constraints(:id => /.*/) do
  # #     resources :attachments
  # #   end
  # # end
end