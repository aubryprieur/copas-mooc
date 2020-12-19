Rails.application.routes.draw do
  devise_for :admins
  devise_for :users
  root "static#homepage"
  resources :workshops

  namespace :admin do
    resources :users
    resources :workshops
  end

end
