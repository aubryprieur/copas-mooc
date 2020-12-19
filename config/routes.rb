Rails.application.routes.draw do
  devise_for :admins, :path => '', :path_names => {:sign_in => 'signin_as_admin', :sign_out => 'signout_as_admin'}, controllers: { sessions: 'admin/sessions' }
  devise_for :users
  root "static#homepage"
  resources :workshops

  namespace :admin do
    root "static_pages#dashboard"
    resources :static_pages
    resources :users
    resources :workshops
  end

end
