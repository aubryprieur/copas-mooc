Rails.application.routes.draw do
  devise_for :admins, :path => '', :path_names => {:sign_in => 'signin_as_admin', :sign_out => 'signout_as_admin'}, controllers: { sessions: 'admin/sessions' }
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
  get "/edit_profile", to: "users#profile"
  get "/edit_avatar", to: "users#avatar"
  root "workshops#index"

  resources :users
  resources :workshops
  resources :lessons do
    collection do
      patch :sort
    end
  end

  resources :workshops do
    resources :lessons
  end

  namespace :admin do
    root "static_pages#dashboard"
    resources :static_pages
    resources :users
    resources :workshops
    resources :lessons
    resources :workshops do
      resources :lessons
    end
  end

end
