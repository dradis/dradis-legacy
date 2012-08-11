Dradis::Core::Engine.routes.draw do
  match '/login' => 'sessions#new', :as => :login
  match '/logout' => 'sessions#destroy', :as => :logout

  resources :categories
  resource :session
end