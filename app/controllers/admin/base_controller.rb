class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  before_action :require_backoffice
  after_action :verify_authorized

  private

  def require_backoffice
    redirect_to root_path, alert: "Espace réservé à l'équipe COPAS." unless current_user.backoffice?
  end
end
