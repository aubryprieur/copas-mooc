Rails.application.routes.draw do
  devise_for :users, path: "compte",
             path_names: { sign_in: "connexion", sign_out: "deconnexion", sign_up: "inscription", edit: "parametres" },
             controllers: { registrations: "users/registrations" }

  root "courses#index"

  # Catalogue public (indicateurs 1 et 2)
  resources :courses, only: %i[index show], path: "formations" do
    resource :enrollment_request, only: %i[new create], path: "demande-inscription"
  end
  get "p/:slug", to: "pages#show", as: :page

  # Réclamations, difficultés, aléas, signalements (ind. 31 et 12) : accessibles à tous
  resources :complaints, only: %i[new create], path: "reclamations"

  # Espace apprenant
  get "mon-espace", to: "dashboard#show", as: :dashboard
  resource :profile, only: %i[edit update], path: "mon-profil"

  resources :enrollments, only: :show, path: "parcours" do
    member do
      get :welcome, path: "accueil"
      post :acknowledge_welcome
      get :certificate, path: "attestation"
    end
    resources :lessons, only: :show, path: "modules" do
      member do
        post :complete
        post :heartbeat
      end
    end
    resources :assessments, only: :show, path: "evaluations" do
      resources :attempts, only: %i[create show], path: "copies"
    end
    resources :surveys, only: %i[new create], path: "questionnaires"
  end

  resources :support_threads, only: %i[index show new create], path: "assistance" do
    resources :support_messages, only: :create, path: "messages"
    patch :close, on: :member
  end

  # Espace de gestion (formateurs, administrateurs ; auditeur en lecture seule)
  namespace :admin, path: "gestion" do
    root "dashboard#show"
    resources :courses, path: "formations" do
      resources :lessons, except: %i[index show], path: "modules" do
        patch :move, on: :member
      end
      resources :assessments, except: :index, path: "evaluations" do
        resources :questions, except: %i[index show]
      end
      get :indicators, on: :member, path: "indicateurs"
    end
    resources :enrollments, only: %i[index show], path: "inscriptions" do
      member do
        patch :approve
        patch :decline
        patch :review_needs
        patch :positioning
        patch :abandon
        get :dossier
      end
      resources :reminders, only: :create
    end
    resources :support_threads, only: %i[index show], path: "assistance" do
      resources :support_messages, only: :create, path: "messages"
    end
    resources :complaints, only: %i[index show update], path: "reclamations"
    resources :surveys, only: :index, path: "satisfaction"
    resources :pages, only: %i[index edit update], path: "pages"
    resources :users, except: :show, path: "utilisateurs"
  end

  get "up" => "rails/health#show", as: :rails_health_check
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
