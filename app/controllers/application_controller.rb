class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user

  rescue_from Pundit::NotAuthorizedError, with: :forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def set_current_user
    Current.user = current_user
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name organization_name organization_type job_title accept_terms])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name])
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || (resource.backoffice? ? admin_root_path : dashboard_path)
  end

  def forbidden
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: "Vous n'avez pas accès à cette page." }
      format.any { head :forbidden }
    end
  end

  def not_found
    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found, layout: "application" }
      format.any { head :not_found }
    end
  end
end
