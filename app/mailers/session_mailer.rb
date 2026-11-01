class SessionMailer < ApplicationMailer
  def invitation
    @enrollment = params[:enrollment]
    @token = params[:password_token]
    setup
    mail(to: @user.email, subject: "Vous êtes inscrit(e) : #{@course.title}")
  end

  def convocation
    @enrollment = params[:enrollment]
    @reminder = params[:reminder]
    setup
    subject = @reminder ? "Rappel : votre formation commence demain" : "Convocation : #{@course.title}, #{@session.dates_label}"
    mail(to: @user.email, subject: subject)
  end

  def client_survey
    @session = params[:session]
    @course = @session.course
    mail(to: @session.organization.contact_email, subject: "Votre avis sur la formation « #{@course.title} »")
  end

  private

  def setup
    @user = @enrollment.user
    @session = @enrollment.course_session
    @course = @session.course
  end
end
