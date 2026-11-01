class ComplaintMailer < ApplicationMailer
  before_action { @complaint = params[:complaint] }

  def acknowledged = mail(to: @complaint.email, subject: "Accusé de réception – demande n° #{@complaint.reference}")
  def responded = mail(to: @complaint.email, subject: "Réponse à votre demande n° #{@complaint.reference}")

  # Les signalements ne transitent pas en clair : le mail invite à se connecter.
  def notify_team
    to = @complaint.report? ? User.where(reports_referent: true).pluck(:email).presence || [ team_address ] : [ team_address ]
    mail(to: to, subject: "Nouvelle demande au registre (#{@complaint.category_label}) – #{@complaint.reference}")
  end
end
