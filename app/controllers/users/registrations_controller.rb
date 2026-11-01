class Users::RegistrationsController < Devise::RegistrationsController
  # Limite la création de comptes en rafale (complète Rack::Attack)
  rate_limit to: 5, within: 10.minutes, only: :create,
             with: -> { redirect_to new_user_registration_path, alert: "Trop de tentatives. Réessayez dans quelques minutes." }
end
