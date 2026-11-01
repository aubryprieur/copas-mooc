class SupportThreadPolicy < BackofficePolicy
  def show? = record.user == user || super
  def reply? = record.user == user || user&.staff?
  def close? = record.user == user || user&.staff?
end
