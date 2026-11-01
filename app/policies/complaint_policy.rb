class ComplaintPolicy < BackofficePolicy
  def show? = super && (!record.report? || user.reports_referent?)
  def update? = user&.staff? && (!record.report? || user.reports_referent?)
  def destroy? = false

  class Scope < BackofficePolicy::Scope
    def resolve = user&.backoffice? ? scope.visible_to(user) : scope.none
  end
end
