Rails.application.routes.draw do

  resources :categories
  resources :configurations

  resources :feeds

  resources :nodes do
    collection { post :sort }
    resources :notes
    constraints(:id => /.*/) do
      resources :attachments
    end
  end

  resource :session
  resources :users

  get '/login' => 'sessions#new', as: :login
  get '/logout' => 'sessions#destroy', as: :logout
  get '/wizard' => 'wizard#index', as: :wizard

  root to: 'home#index'
end
