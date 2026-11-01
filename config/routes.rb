Rails.application.routes.draw do
  devise_for :users, path: "compte",
             path_names: { sign_in: "connexion", sign_out: "deconnexion", sign_up: "inscription", edit: "parametres" },
             controllers: { registrations: "users/registrations" }

  root "courses#index"

  # Catalogue public (indicateurs 1 et 2)
  resources :courses, only: %i[index show], path: "formations" do
    resource :enrollment_request, only: %i[new create], path: "demande-inscription"
    resource :training_request, only: %i[new create], path: "demande-structure"
  end
  get "p/:slug", to: "pages#show", as: :page

  # Réclamations, difficultés, aléas, signalements (ind. 31 et 12) : accessibles à tous
  resources :complaints, only: %i[new create], path: "reclamations"

  # Espace apprenant
  get "mon-espace", to: "dashboard#show", as: :dashboard
  resource :profile, only: %i[edit update], path: "mon-profil"

  # Émargement électronique (sessions sur site) et avis du commanditaire (lien sécurisé, sans compte)
  get "emargement/:token", to: "signatures#show", as: :sign_slot
  post "emargement/:token", to: "signatures#create"
  get "structure/:token/questionnaire", to: "client_surveys#new", as: :new_client_survey
  post "structure/:token/questionnaire", to: "client_surveys#create", as: :client_survey

  resources :enrollments, only: :show, path: "parcours" do
    resource :needs_assessment, only: %i[new create], path: "besoins"
    get "supports/:attachment_id", to: "materials#show", as: :material
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
    get "aujourdhui", to: "today#show", as: :today
    resources :training_requests, only: %i[index show update], path: "demandes-structures"
    resources :organizations, except: :show, path: "structures"
    resources :locations, except: :show, path: "lieux"
    resources :course_sessions, path: "sessions" do
      member do
        get :sheet, path: "feuille-emargement"
        get :attendance_report, path: "emargement-signe"
        get :completion_certificates, path: "certificats-realisation"
        post :send_convocations
        post :send_client_survey
        delete "supports/:attachment_id", action: :remove_material, as: :remove_material
      end
      resources :participants, only: %i[new create destroy]
    end
    resources :session_slots, only: :show, path: "emargement" do
      member do
        patch :open
        patch :close
        patch :trainer_sign
        post :photo
        patch :mark
        get :tablet
        post :tablet_sign
      end
    end
    resources :attendances, only: :update
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
