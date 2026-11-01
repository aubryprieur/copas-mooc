class SupportMessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    thread = current_user.support_threads.find(params[:support_thread_id])
    message = thread.messages.new(author: current_user, body: params.dig(:support_message, :body))
    if message.save
      redirect_to support_thread_path(thread, anchor: "message-#{message.id}")
    else
      redirect_to support_thread_path(thread), alert: "Le message est vide."
    end
  end
end
