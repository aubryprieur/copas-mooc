class PagePolicy < BackofficePolicy
  def update? = user&.admin?
  def create? = user&.admin?
end
