Rails.application.routes.draw do
  devise_for :users
  root "static#homepage"
  resources :workshops
end
