Dradis::Application.routes.draw do
  resources :users
  resource :session
  match '/login' => 'sessions#new', :as => :login
  match '/logout' => 'sessions#destroy', :as => :logout

  match '/wizard' => 'wizard#index', :as => :wizard

  resources :configurations
  resources :categories
  resources :feeds

  resources :nodes do
    resources :notes
    constraints(:id => /.*/) do
      resources :attachments
    end
  end

  root :to => 'home#index'
  match '/:controller(/:action(/:id))'
end
