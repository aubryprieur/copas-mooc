class AttendancePolicy < BackofficePolicy
  def update? = user&.staff? && (user.admin? || record.session_slot.course_session.trainer_id == user.id)
end
