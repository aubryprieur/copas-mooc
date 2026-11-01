# Sessions sur site : l'administrateur gère tout ; le formateur gère les sessions qu'il anime ; l'auditeur consulte.
class CourseSessionPolicy < BackofficePolicy
  def create? = user&.admin?
  def update? = user&.admin? || (user&.trainer? && record.trainer_id == user.id)
  def destroy? = user&.admin? && record.enrollments.none?
  def manage_participants? = user&.admin?
  def documents? = user&.backoffice?

  class Scope < BackofficePolicy::Scope
    def resolve
      return scope.none unless user&.backoffice?
      return scope.all if user.admin? || user.auditor?

      scope.where(trainer: user)
    end
  end
end
