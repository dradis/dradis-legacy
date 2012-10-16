Dradis::Core::Engine.routes.draw do
  match '/login' => 'sessions#new', :as => :login
  match '/logout' => 'sessions#destroy', :as => :logout

  # Resources
  resources :categories
  resources :nodes do
    collection { post :sort }
    resources :notes do
      resources :attachments
    end
  end
  resource :session

  # Plugins
  # match '/export/:action' => 'export#:action'

  root :to => 'home#index'

  # Dradis 2.x routes
  # -----------------
  # resources :configurations
  # resources :feeds
  # 
  # resources :nodes do
  #   collection { post :sort }
  #   resources :notes
  #   constraints(:id => /.*/) do
  #     resources :attachments
  #   end
  # end
  # 
  # root :to => 'home#index'
end