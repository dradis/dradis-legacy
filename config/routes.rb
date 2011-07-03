Dradis::Application.routes.draw do
  resources :users
  resource :session
  match '/login' => 'sessions#new', :as => :login
  match '/logout' => 'sessions#destroy', :as => :logout

  match 'nodes/:node_id/attachments/:id' => 'attachments#show', :constraints => { :id => /.*/ }

  resources :configurations
  resources :categories
  resources :feeds
  resources :nodes do
    resources :notes
    resources :attachments
  end

  root :to => 'home#index'
  match '/:controller(/:action(/:id))'
end
