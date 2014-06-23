Rails.application.routes.draw do
  mount Frontend.engine => '/', as: 'frontend'
end
