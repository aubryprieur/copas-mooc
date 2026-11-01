class TrainingRequestPolicy < BackofficePolicy
  def create? = user&.admin?
  def update? = user&.admin?
end
