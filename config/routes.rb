Rails.application.routes.draw do
  mount Dradis::Frontend::Engine => '/', as: 'frontend'
end
