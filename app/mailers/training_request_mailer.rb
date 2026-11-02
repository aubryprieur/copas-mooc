class TrainingRequestMailer < ApplicationMailer
  before_action { @request = params[:request]; @course = @request.course }

  def acknowledged = mail(to: @request.contact_email, subject: "Votre demande de formation : #{@course.title}")
  def notify_team = mail(to: team_address, subject: "Demande de formation sur site : #{@request.organization_name} – #{@course.title}")
end
