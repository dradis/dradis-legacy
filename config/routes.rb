Dradis::Application.routes.draw do
  resources :users
  resource :session
  match '/login' => 'sessions#new', :as => :login
  match '/logout' => 'sessions#destroy', :as => :logout

  resources :configurations
  resources :categories
  resources :feeds
  resources :nodes do
    resources :notes
    resources :attachments
  end

  match '/' => 'home#index'
  match '/:controller(/:action(/:id))'
end
