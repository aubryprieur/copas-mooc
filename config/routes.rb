Rails.application.routes.draw do
  devise_for :admins, :path => '', :path_names => {:sign_in => 'signin_as_admin', :sign_out => 'signout_as_admin'}, controllers: { sessions: 'admin/sessions' }
  devise_for :users, controllers: { sessions: 'users/sessions' }
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  get "/edit_profile", to: "users#profile"
  get "/edit_avatar", to: "users#avatar"

  root "workshops#index"

  resources :users
  resources :workshops do
    resources :lessons
  end
  resources :lessons do
    collection do
      patch :sort
    end
  end

  resources :lessons do
    resources :comments
  end

  resources :users do
    resources :comments
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
