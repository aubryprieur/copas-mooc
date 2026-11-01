# Indicateur 30 : questionnaire à froid envoyé 90 jours après la fin du parcours.
class ColdSurveyJob < ApplicationJob
  queue_as :default
  DELAY = 90.days

  def perform
    Enrollment.completed.where(cold_survey_sent_at: nil).where(completed_at: ..DELAY.ago).find_each do |enrollment|
      next if enrollment.cold_survey

      SurveyMailer.with(enrollment: enrollment).cold.deliver_later
      enrollment.update_column(:cold_survey_sent_at, Time.current)
    end
  end
end
