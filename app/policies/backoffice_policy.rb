# Espace de gestion : formateurs et administrateurs modifient, l'auditeur consulte seulement.
class BackofficePolicy < ApplicationPolicy
  def index? = user&.backoffice?
  def show? = user&.backoffice?
  def create? = user&.staff?
  def update? = user&.staff?
  def destroy? = user&.admin?
  def export? = user&.backoffice?

  class Scope < ApplicationPolicy::Scope
    def resolve = user&.backoffice? ? scope.all : scope.none
  end
end
