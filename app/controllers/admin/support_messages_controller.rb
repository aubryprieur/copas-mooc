class Admin::SupportMessagesController < Admin::BaseController
  def create
    thread = SupportThread.find(params[:support_thread_id])
    authorize thread, :reply?
    message = thread.messages.new(author: current_user, body: params.dig(:support_message, :body))
    if message.save
      redirect_to admin_support_thread_path(thread), notice: "Réponse envoyée à l'apprenant."
    else
      redirect_to admin_support_thread_path(thread), alert: "La réponse est vide."
    end
  end
end
