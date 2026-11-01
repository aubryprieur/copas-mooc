class UserPolicy < BackofficePolicy
  # Seul un administrateur gère les comptes et les rôles.
  def create? = user&.admin?
  def update? = user&.admin?
  def destroy? = user&.admin? && record != user
end
