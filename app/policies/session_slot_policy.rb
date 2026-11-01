class SessionSlotPolicy < BackofficePolicy
  def show? = user&.backoffice? && (user.admin? || user.auditor? || record.course_session.trainer_id == user.id)
  def manage? = user&.staff? && (user.admin? || record.course_session.trainer_id == user.id)
end
