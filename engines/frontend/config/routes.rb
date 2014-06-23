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

  root to: 'home#index'
end