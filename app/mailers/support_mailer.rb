class SupportMailer < ApplicationMailer
  before_action { @message = params[:message]; @thread = @message.support_thread }

  def new_question
    to = [ @thread.enrollment&.course&.trainer&.email, team_address ].compact.uniq
    mail(to: to, subject: "[#{@thread.category_label}] #{@thread.subject}")
  end

  def reply_to_learner = mail(to: @thread.user.email, subject: "Réponse à votre demande : #{@thread.subject}")
end
