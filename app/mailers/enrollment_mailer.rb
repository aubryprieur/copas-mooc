class EnrollmentMailer < ApplicationMailer
  before_action { @enrollment = params[:enrollment]; @course = @enrollment.course; @user = @enrollment.user }

  def requested = mail(to: @user.email, subject: "Demande d'inscription reçue : #{@course.title}")
  def notify_team = mail(to: team_address, subject: "Nouvelle demande d'inscription : #{@user.full_name} – #{@course.title}")
  def approved = mail(to: @user.email, subject: "Votre inscription est validée : #{@course.title}")
  def declined = mail(to: @user.email, subject: "Votre demande d'inscription : #{@course.title}")
  def completed = mail(to: @user.email, subject: "Formation terminée : votre attestation est disponible")
end
