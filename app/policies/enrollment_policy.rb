class EnrollmentPolicy < BackofficePolicy
  # Côté apprenant : seul le titulaire accède à son parcours.
  def learn? = record.user == user && (record.active? || record.completed?)
  def onboard? = record.user == user && record.onboarding?
  def owner? = record.user == user
  def certificate? = (owner? || user&.backoffice?) && record.completed?
  def remind? = user&.staff? && record.active?
  def destroy? = false
end
