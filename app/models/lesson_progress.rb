class LessonProgress < ApplicationRecord
  belongs_to :enrollment
  belongs_to :lesson

  # Plafond par signal de présence : évite de compter un onglet resté ouvert.
  MAX_HEARTBEAT_SECONDS = 60

  def completed? = completed_at.present?

  def record_view!
    now = Time.current
    update!(first_viewed_at: first_viewed_at || now, last_viewed_at: now)
  end

  def add_active_time!(seconds)
    increment!(:active_seconds, seconds.to_i.clamp(0, MAX_HEARTBEAT_SECONDS))
  end
end
