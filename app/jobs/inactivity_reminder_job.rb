# Indicateur 19 (2026) : relances en cas d'inactivité prolongée et alertes de décrochage.
# Exécuté chaque matin (config/recurring.yml).
class InactivityReminderJob < ApplicationJob
  queue_as :default

  def perform
    Enrollment.active.includes(:course, :user, :reminders).find_each do |enrollment|
      days = enrollment.days_inactive
      next if days.nil?

      since = enrollment.last_activity_at || enrollment.started_at
      course = enrollment.course

      if days >= course.inactivity_alert_days && !reminded?(enrollment, :alert, since)
        reminder = enrollment.reminders.create!(kind: :alert, sent_at: Time.current,
                                                message: "Aucune activité depuis #{days} jours.")
        ReminderMailer.with(reminder: reminder).dropout_alert.deliver_later
      elsif days >= course.inactivity_reminder_days && !reminded?(enrollment, :automatic, since)
        reminder = enrollment.reminders.create!(kind: :automatic, sent_at: Time.current,
                                                message: "Relance automatique après #{days} jours sans activité.")
        ReminderMailer.with(reminder: reminder).automatic.deliver_later
      end
    end
  end

  private

  def reminded?(enrollment, kind, since)
    enrollment.reminders.any? { |r| r.kind == kind.to_s && (since.nil? || r.sent_at > since) }
  end
end
