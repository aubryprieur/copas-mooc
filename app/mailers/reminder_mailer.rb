class ReminderMailer < ApplicationMailer
  before_action do
    @reminder = params[:reminder]
    @enrollment = @reminder.enrollment
    @course = @enrollment.course
    @user = @enrollment.user
  end

  def automatic = mail(to: @user.email, subject: "On continue ? Votre formation « #{@course.title} » vous attend")
  def manual = mail(to: @user.email, reply_to: @reminder.sent_by&.email, subject: "Un message de votre formateur : #{@course.title}")

  def dropout_alert
    recipients = [ @course.pedagogical_referent&.email, @course.trainer&.email, team_address ].compact.uniq
    mail(to: recipients, subject: "Alerte de décrochage : #{@user.full_name} – #{@course.title}")
  end
end
