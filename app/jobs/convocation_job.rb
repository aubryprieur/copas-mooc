# Indicateur 9 : convocation à J-7 et rappel à J-1 pour les sessions sur site.
class ConvocationJob < ApplicationJob
  queue_as :default

  def perform(today: Date.current)
    CourseSession.where(status: %i[planned confirmed]).includes(:slots, enrollments: :user).find_each do |session|
      start = session.start_date
      next if start.nil?

      if start <= today + 7 && start > today && session.convocations_sent_at.nil?
        send_all(session, reminder: false)
        session.update!(convocations_sent_at: Time.current)
      elsif start == today + 1 && session.reminders_sent_at.nil?
        send_all(session, reminder: true)
        session.update!(reminders_sent_at: Time.current)
      end
    end
  end

  def send_all(session, reminder:)
    session.participants.each do |enrollment|
      next if enrollment.declined? || enrollment.abandoned?

      SessionMailer.with(enrollment: enrollment, reminder: reminder).convocation.deliver_later
      enrollment.log!(reminder ? "convocation.reminder" : "convocation.sent", user: nil, subject: session)
    end
  end
end
