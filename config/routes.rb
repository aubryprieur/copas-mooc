Rails.application.routes.draw do
  devise_for :admins, :path => '', :path_names => {:sign_in => 'signin_as_admin', :sign_out => 'signout_as_admin'}, controllers: { sessions: 'admin/sessions' }
  devise_for :users, controllers: { sessions: 'users/sessions' }
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  devise_scope :admin do
    get '/signout_as_admin' => 'devise/sessions#destroy'
  end

  get "/edit_profile", to: "users#profile"
  get "/edit_avatar", to: "users#avatar"

  resources :complete_lessons, only: [:create, :destroy]

  root "workshops#index"

  get 'payment-complete', :to => 'purchases#payment_complete', as: 'payment_complete'

  resource :purchase

  resources :users
  resources :workshops do
    resources :lessons
  end
  resources :lessons do
    collection do
      patch :sort
    end
  end

  resources :workshops do
    resources :questions
  end
  resources :questions do
    collection do
      patch :sort
    end
  end

  resources :questions do
    resources :answers
  end

  resources :lessons do
    resources :comments
  end

  resources :users do
    resources :comments
  end

  resources :workshops do
    resources :enrollments
  end

  resources :workshops do
    get '/results', to: 'results#results'
  end

  resources :enrollments, only: [:index]

  namespace :admin do
    root "static_pages#dashboard"
    resources :static_pages
    resources :users
    resources :workshops
    resources :lessons
    resources :questions
    resources :workshops do
      resources :lessons
    end
    resources :workshops do
      resources :questions
    end
  end

end
